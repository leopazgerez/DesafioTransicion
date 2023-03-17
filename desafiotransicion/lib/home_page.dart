import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'animated_circle.dart';
import 'globals.dart';
import 'home_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin{

  late AnimationController _animationController;
  late Animation<double> _starAnimation;
  late Animation<double> _endAnimation;
  late Animation<double> _horizontalAnimation;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();

    _pageController = PageController();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 750));
    _starAnimation = CurvedAnimation(parent: _animationController, curve: const Interval(0, 0.5, curve: Curves.easeInExpo));
    _endAnimation = CurvedAnimation(parent: _animationController, curve: const Interval(0.750, 1.000, curve: Curves.easeInOutExpo));
    _horizontalAnimation = CurvedAnimation(parent: _animationController, curve: const Interval(0.750, 1.000, curve: Curves.easeInOutQuad));

    _animationController.addStatusListener((status) {
      final model = Provider.of<HomeModel>(context, listen: false);
      if (status == AnimationStatus.completed) {
        model.swapColors();
        _animationController.reset();
      }
    });

    _animationController.addListener(() {
      final model = Provider.of<HomeModel>(context, listen: false);
      if (_animationController.value > 0.5) {
        model.isHalfWay = true;
      } else {
        model.isHalfWay = false;
      }});

  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<HomeModel>(context, listen: true);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor:
      model.isHalfWay ? model.foreGroundColor : model.backGroundColor,
      body: Stack(
        children: <Widget>[
          Container(
            color:
            model.isHalfWay ? model.foreGroundColor : model.backGroundColor,
            width: screenWidth / 2.0 - Global.radius / 2.0,
            height: double.infinity,
          ),
          Transform(
            transform: Matrix4.identity()
              ..translate(
                screenWidth / 2 - Global.radius / 2.0,
                screenHeight - Global.radius - Global.bottomPadding,
              ),
            child: GestureDetector(
              onTap: () {
                if (_animationController.status != AnimationStatus.forward) {
                  model.isToggled = !model.isToggled;
                  model.index++;
                  if (model.index > 3) {
                    model.index = 0;
                  }
                  _pageController.animateToPage(model.index,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOutQuad);
                  _animationController.forward();
                }
              },
              child: Stack(
                children: <Widget>[
                  AnimatedCircle(
                    animation: _starAnimation,
                    color: model.foreGroundColor,
                    flip: 1.0,
                    tween: Tween<double>(begin: 1.0, end: Global.radius),
                  ),
                  AnimatedCircle(
                    animation: _endAnimation,
                    color: model.backGroundColor,
                    flip: -1.0,
                    horizontalTween:
                    Tween<double>(begin: 0, end: -Global.radius),
                    horizontalAnimation: _horizontalAnimation,
                    tween: Tween<double>(begin: Global.radius, end: 1.0),
                  ),
                ],
              ),
            ),
          ),
          IgnorePointer(
            ignoring: true,
            child: PageView.builder(
              controller: _pageController,
              itemCount: 4,
              itemBuilder: (context, index) {
                return Center(
                  child: Text(
                    'Page ${index + 1}',
                    style: TextStyle(
                      color: index % 2 == 0 ? Global.mediumBlue : Global.white,
                      fontSize: 30.0,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}