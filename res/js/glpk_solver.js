//import {
//  glp_add_cols,
//  glp_add_rows,
//  glp_create_prob, glp_get_col_prim, glp_get_obj_val,
//  glp_intopt,
//  GLP_IV,
//  GLP_LO,
//  glp_load_matrix,
//  GLP_MIN,
//  glp_mip_col_val, glp_mip_obj_val,
//  glp_set_col_bnds,
//  glp_set_col_kind,
//  glp_set_col_name,
//  glp_set_obj_coef,
//  glp_set_obj_dir,
//  glp_set_print_func,
//  glp_set_row_bnds,
//  glp_set_row_name,
//  glp_simplex
//} from "./glpk.min";

function log(msg) {
//  console.log(msg)
}

function get_param(params, key, default_value) {
  if (params[key] === undefined) {
    return default_value;
  } else {
    return params[key];
  }
}

// noinspection JSUnusedLocalSymbols
function glpk_solver(params_str) {
  let t0 = new Date().getTime();

  // input vars
  //    min cx
  //    Ax>=b
  //    A:m*n
  let params = JSON.parse(params_str)
  let col_names = get_param(params, 'colNames'); //n
  let row_names = get_param(params, 'rowNames');//m
  let b = get_param(params, 'bVec');//m
  let c = get_param(params, 'cVec');//n
  let A = get_param(params, 'AMat');
  let integer = get_param(params, 'integer', false);

  // solver
  let col_count = col_names.length
  let row_count = row_names.length;

  glp_set_print_func(log);
  let lp = glp_create_prob();
  glp_set_obj_dir(lp, GLP_MIN); // optimization direction flag - minimization
  glp_add_cols(lp, col_count);
  glp_add_rows(lp, row_count);

  // columns settings, boundary: [0, INF)]
  for (let i = 0; i < col_count; i++) {
    glp_set_col_name(lp, i + 1, col_names[i]);        // col_name
    glp_set_col_bnds(lp, i + 1, GLP_LO, 0, 0);  // lower boundary
    glp_set_col_kind(lp, i + 1, GLP_IV);    // integer variable ? if only use simplex, may take no effect
  }

  //rows, boundary: [obj num, INF)
  for (let i = 0; i < row_count; i++) {
    let row_name = row_names[i];
    glp_set_row_name(lp, i + 1, row_name);
    glp_set_row_bnds(lp, i + 1, GLP_LO, b[i] || 0, 0);
  }

  // coefficient: ap or num
  for (let i = 0; i < col_count; i++) {
    glp_set_obj_coef(lp, i + 1, c[i]); // sum(a_i*x_i)
  }

  // constraint_matrix
  // A[ia,aj]=ar; sparse matrix
  let ia = [null];
  let ja = [null];
  let ar = [null];

  for (let i = 0; i < row_count; i++) {
    for (let j = 0; j < col_count; j++) {
      if (A[i][j] > 0) {
        ia.push(i + 1);
        ja.push(j + 1);
        ar.push(A[i][j]);
      }
    }
  }
  // log('ia=' + ia);
  // log('ja=' + ja);
  // log('ar=' + ar);
  glp_load_matrix(lp, ar.length - 1, ia, ja, ar); //lp,m*n=max_size,ia,ja,ar

  // solve: simplex then integer optimization(VERY SLOW!)
  glp_simplex(lp, null);
  if (integer) {
    glp_intopt(lp, null);
  }

  // results
  log('------------ Summary ------------');
  let _total_obj = integer ? glp_mip_obj_val(lp) : glp_get_obj_val(lp)
  log(`total objective: ${_total_obj}`)
  let results = {}
  for (let col_no = 0; col_no < col_count; col_no++) {
    let col_v = integer ? glp_mip_col_val(lp, col_no + 1) : glp_get_col_prim(lp, col_no + 1);
    if (col_v !== 0) {
      results[col_names[col_no]] = col_v
    }
  }
  log(`results: ${results}`)
  let t1 = new Date().getTime();
  log(`Time: ${((t1 - t0) / 1000).toPrecision(4)} s.`);
  log('---------- End Summary ----------');
  return JSON.stringify(results)
}