//@dart=2.12
import 'package:chaldea/components/components.dart';

class BlankPage extends StatelessWidget {
  const BlankPage({Key? key}) : super(key: key);

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

              /// If show progress
            ],
          ),
        ),
      );
    });
  }
}
