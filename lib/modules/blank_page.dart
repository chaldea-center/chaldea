import 'package:chaldea/components/components.dart';

class BlankPage extends StatelessWidget {
  final bool showProgress;

  const BlankPage({Key key, this.showProgress = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                    maxWidth: constraints.biggest.width * 0.5,
                    maxHeight: constraints.biggest.height * 0.5),
                child: Image(image: AssetImage("res/img/chaldea.png")),
              ),
              if (showProgress)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: CircularProgressIndicator(),
                )
            ],
          ),
        ),
      );
    });
  }
}
