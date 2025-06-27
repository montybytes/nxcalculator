import 'package:flutter/material.dart';

import 'components/main_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<dynamic> _items = [
    "delete",
    "inverse",
    "percent",
    "divide",
    "7",
    "8",
    "9",
    "multiply",
    "4",
    "5",
    "6",
    "minus",
    "1",
    "2",
    "3",
    "add",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: Text(
          "Calculator",
          style: TextStyle(
            fontFamily: "Ntype-82",
            fontSize: 40,
            letterSpacing: -1.4,
          ),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.menu)),
          SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(child: SizedBox()),
                  GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _items.length,
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 1,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemBuilder: (context, index) {
                      Color color = Color(0xFF1C1C1C);

                      if (index == 0) {
                        color = Color(0xFFD71921);
                      }

                      if (index % 4 == 3) {
                        color = Color(0xFFe3e3e3);
                      }

                      return MainButton(
                        color: color,
                        drawablePath: "assets/icons/${_items[index]}.svg",
                      );
                    },
                  ),
                  SizedBox(height: 8),
                  SizedBox(
                    height: constraints.maxWidth / 4 - 4,
                    child: Row(
                      children: [
                        MainButton(
                          color: Color(0xFF1C1C1C),
                          drawablePath: "assets/icons/0.svg",
                          width: constraints.maxWidth / 2 - 4,
                        ),

                        SizedBox(width: 8),
                        Flexible(
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: MainButton(
                              color: Color(0xFF1C1C1C),
                              drawablePath: "assets/icons/decimal.svg",
                            ),
                          ),
                        ),
                        SizedBox(width: 8),

                        Flexible(
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: MainButton(
                              color: Color(0xFFD71921),
                              drawablePath: "assets/icons/equals.svg",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}