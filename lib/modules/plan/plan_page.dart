import 'dart:convert';

import 'package:chaldea/components/components.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_liquidcore/liquidcore.dart';

class PlanPage extends StatefulWidget {
  @override
  _PlanPageState createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  JSContext _jsContext;
  GLPKParams params = GLPKParams();
  List<TextEditingController> _controllers = [];
  GLPKSolution result;

  @override
  void initState() {
    super.initState();
    params.addOne(db.gameData.glpk.rowNames[0]);
    params.addOne(db.gameData.glpk.rowNames[1]);
    params.objNum.forEach((v) {
      _controllers.add(TextEditingController(text: v.toString()));
    });
    _loadLib();
  }

  @override
  Widget build(BuildContext context) {
    // todo: add controllers
    return Scaffold(
      appBar: AppBar(
        title: Text('Plans'),
        leading: BackButton(),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              shrinkWrap: true,
              children: [
                TileGroup(
                  children: <Widget>[
                    for (var i = 0; i < params.objRows.length; i++)
                      ListTile(
                        title: Row(
                          children: <Widget>[
                            Expanded(
                                child: DropdownButton(
                                    underline: Container(),
                                    value: params.objRows[i],
                                    items: db.gameData.glpk.rowNames
                                        .map((e) => DropdownMenuItem(
                                            child: Text(e), value: e))
                                        .toList(),
                                    onChanged: (v) {
                                      setState(() {
                                        params.objRows[i] = v;
                                      });
                                    })),
                            Expanded(
                                child: TextField(
                              controller: _controllers[i],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              inputFormatters: [
                                WhitelistingTextInputFormatter.digitsOnly
                              ],
                              onChanged: (s) {
                                params.objNum[i] = int.tryParse(s) ?? 0;
                              },
                            )),
                          ],
                        ),
                        trailing: IconButton(
                            icon: Icon(Icons.delete_outline,
                                color: Colors.redAccent),
                            onPressed: () {
                              setState(() {
                                params.removeAt(i);
                                _controllers.removeAt(i);
                              });
                            }),
                      ),
                  ],
                ),
                TileGroup(
                  header: 'Solution',
                  children: <Widget>[
                    ListTile(
                      title: Text('Total Num: ${result?.totalNum}'),
                      trailing: Text('Total AP: ${result?.totalEff}'),
                    ),
                    for (var i = 0;
                        i < (result?.solutionKeys?.length ?? 0);
                        i++)
                      ListTile(
                        title: Text(result.solutionKeys[i]),
                        subtitle: Text('item*n, ...'),
                        trailing: Text('${result.solutionValues[i]}*?AP'),
                      ),
                  ],
                )
              ],
            ),
          ),
          ButtonBar(
            children: <Widget>[
              IconButton(
                  icon: Icon(Icons.add_circle),
                  onPressed: () {
                    setState(() {
                      params.addOne(db.gameData.glpk.rowNames.first);
                      _controllers
                          .add(TextEditingController(text: 0.toString()));
                    });
                  }),
              RaisedButton(
                onPressed: () {
                  if (params.objRows.length > 0 && sum(params.objNum) > 0) {
                    calculatePlan();
                  } else {
                    showToast('invalid input');
                  }
                },
                child: Text('Solve'),
              )
            ],
          )
        ],
      ),
    );
  }

  void _loadLib() async {
    String glpkLib = await rootBundle.loadString('res/lib/glpk.min.js');
    _jsContext = JSContext();
    await _jsContext.evaluateScript(glpkLib);
    await _jsContext.evaluateScript(r'''
function solve_glpk(data_str, params_str) {
    var t0 = new Date().getTime();
    var data = JSON.parse(data_str);
    var params = JSON.parse(params_str);
    // (default) params
    // row keys, string list
    var obj_rows = params['objRows'];
    // required, array b in Ax >= b, int list.
    var obj_num = params['objNum'];
    // skip if coeff < min_coeff
    var min_coeff = params['minCoeff'] || 0;
    // skip if col not in first max_sort_order of every row key's sorting
    var max_sort_order = params['maxSortOrder'] || Infinity;
    // if true, use coeff, minimize eff; else coeff=1, minimize num.
    var coeff_prio = params['coeffPrio'] || true;
    // if cn server, decide to skip which cols.
    var use_cn = params['useCn'] || false;

    // max_sort_order
    var filtered_cols = new Set();
    for (let i = 0; i < obj_rows.length; i++) {
        var index = data.rowNames.indexOf(obj_rows[i]);
        var sort_cols = [];
        for (let i = 0; i < data.colNames.length; i++) {
            if (data.matrix[index][i] > 0) {
                sort_cols.push([data.colNames[i], data.coeff[i] / data.matrix[index][i]]);
            } else {
                sort_cols.push([data.colNames[i], 0]);
            }
        }
        sort_cols.sort(function (a, b) {
            return b[1] - a[1];
        });
        for (let i = 0; i < sort_cols.length; i++) {
            if (i < max_sort_order) {
                filtered_cols.add(sort_cols[i][0]);
            }
        }
    }
    // console.log(`filtered: ${Array.from(filtered_cols)}`);

    var col_count = data.colNames.length

    glp_set_print_func(console.log);
    var lp = glp_create_prob();
    glp_set_obj_dir(lp, GLP_MIN); // optimization direction flag - minimization
    glp_add_cols(lp, col_count);
    glp_add_rows(lp, obj_rows.length);
    // columns settings, boundary: [0, INF)]
    for (var i = 0; i < col_count; i++) {
        glp_set_col_name(lp, i + 1, data.colNames[i]);  // col_name
        glp_set_col_bnds(lp, i + 1, GLP_LO, 0, 0);      // lower boundary
        glp_set_col_kind(lp, i + 1, GLP_IV);            // integer variable 
    }

    //rows, boundary: [obj_num, INF)
    for (var i = 0; i < obj_rows.length; i++) {
        glp_set_row_name(lp, i + 1, obj_rows[i]);
        glp_set_row_bnds(lp, i + 1, GLP_LO, obj_num[i], 0);
    }

    // coefficient: ap or num
    for (var i = 0; i < col_count; i++) {
        if (coeff_prio == true) {
            glp_set_obj_coef(lp, i + 1, data.coeff[i]); // sum(a_i*x_i)
        } else {
            glp_set_obj_coef(lp, i + 1, 1);// sum(x_i)=num
        }
    }

    //constrant_matrix
    // A[ia,aj]=ar; sparse matrix
    var ia = [null];
    var ja = [null];
    var ar = [null];

    for (var i = 0; i < obj_rows.length; i++) {
        var index = data.rowNames.indexOf(obj_rows[i]);
        console.log(`row[${index}]=${data.rowNames[index]}, num=${obj_num[i]}`);
        // console.log(`  row_data=${data.matrix[index]}`);

        for (var j = 0; j < col_count; j++) {
            if (use_cn == true && (j >= 198 || j == 150)) {
                // WARNING: update conditions if needed.
                continue
            }
            if (data.matrix[index][j] > 0 && filtered_cols.has(data.colNames[j]) && data.coeff[j] >= min_coeff) {
                ia.push(i + 1);
                ja.push(j + 1);
                ar.push(data.coeff[j] / data.matrix[index][j]);
            }
        }
    }
    // console.log('ia=' + ia);
    // console.log('ja=' + ja);
    // console.log('ar=' + ar);
    glp_load_matrix(lp, ar.length - 1, ia, ja, ar);//lp,m*n=max_size,ia,ja,ar

    // solve: simplex then integer opt
    glp_simplex(lp, null);
    glp_intopt(lp, null);

    // results
    console.log('------------ Summary ------------');
    var total_eff = glp_mip_obj_val(lp);
    var total_num = 0;
    var solution_keys = new Array(), solution_values = new Array();

    for (var i = 0; i < col_count; i++) {
        if (glp_mip_col_val(lp, i + 1) != 0) {
            var v = glp_mip_col_val(lp, i + 1);
            total_num += v;
            solution_keys.push(data.colNames[i]);
            solution_values.push(v);
            console.log(`result ${i + 1}, AP ${data.coeff[i]}, ${v} times. col=${data.colNames[i]}`);
        }
    }
    console.log(`total_eff=${total_eff}, total_num=${total_num}.`); // min AP
    var t1 = new Date().getTime();
    console.log(`Time: ${(t1 - t0) / 1000} s.`);
    console.log('---------- End Summary ----------');
    return {
        "totalEff": total_eff,
        "totalNum": total_num,
        "solutionKeys": solution_keys,
        "solutionValues": solution_values
    }
}
''');
  }

  void calculatePlan() async {
    if (_jsContext == null) {
      print('_jsContext is null.');
      return;
    }

    try {
      final t0 = DateTime.now();
      await _jsContext.evaluateScript('''
    var data_str = `${json.encode(db.gameData.glpk.toJson())}`;
    var params_str = `${json.encode(params.toJson())}`;
    var result = solve_glpk(data_str,params_str);
    ''');
      result =
          GLPKSolution.fromJson(Map.from(await _jsContext.property('result')));
      result.sortByValue();
      print('--result---\n${result.toJson()}');
      final t1 = DateTime.now();
      print('-- glpk time: ${t1.difference(t0).inMilliseconds / 1000} sec ---');
      setState(() {});
    } catch (e) {
      print('_jsContext error\n$e');
      showToast('js eror: $e');
    }
  }
}
