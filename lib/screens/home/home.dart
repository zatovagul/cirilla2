import 'package:cirilla/service/messaging.dart';
import 'package:cirilla/mixins/mixins.dart';
import 'package:cirilla/models/models.dart';
import 'package:cirilla/screens/screens.dart';
import 'package:cirilla/store/store.dart';
import 'package:cirilla/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:provider/provider.dart';

import 'widgets/drawer.dart';
import 'widgets/tab_home.dart';
import 'widgets/tabs.dart';
import 'widgets/empty.dart';

/// Static screens
Map<String, Widget> widgetOptions = {
  'screens_home': TabHome(),
  "screens_category": ProductCategoryScreen(),
  "screens_wishlist": WishListScreen(),
  "screens_cart": CartScreen(),
  "screens_profile": ProfileScreen(),
  "screens_postCategory": PostCategoryScreen(),
  "screens_postWishlist": PostWishlistScreen(),
  "screens_vendorList": VendorListScreen(),
};

class HomeScreen extends StatefulWidget {
  static const routeName = '/';

  final SettingStore store;
  final Map<String, dynamic> args;

  const HomeScreen({Key key, this.store, this.args}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with Utility, MessagingMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _drawerController = ZoomDrawerController();
  ProductCategoryStore _categoryStore;
  MessageStore _messageStore;
  AuthStore _authStore;

  @override
  void initState() {
    subscribe(widget.store.requestHelper, _getMessages);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _categoryStore = Provider.of<ProductCategoryStore>(context);
    _messageStore = Provider.of<MessageStore>(context);
    _authStore = Provider.of<AuthStore>(context);
  }

  void _getMessages() {
    if (_messageStore != null) {
      _messageStore.getMessages();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Set transparent status bar on Android
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    return Observer(
      builder: (_) {
        bool loading = widget.store.loading;
        return Stack(
          children: [
            widget.store.data == null ? Empty() : buildOnBoarding(context, widget.store.enableGetStart),
            if(showInfo)
              getInfoText(),
            SplashScreen(loading: loading, color: Colors.white),
          ],
        );
      },
    );
  }
  /// по просьбе заказчика
  bool showInfo = true;
  Widget getInfoText()=>Container(
    color: Colors.white,
    child: SafeArea(
      child: Stack(
        children: [
          Center(
            child: Html(data: """
      <p style="text-align:center;color:red"><strong>Уважаемые гости,</strong><br><strong>мы рады приветствовать вас на территории Республики Дагестан!</strong></p>
<p style="text-align:center">Приезжая к нам в республику, вы имеете разные цели и планы, но несмотря на это, вы все будете жить рядом и взаимодействовать с местными жителями &ndash; многонациональным народом Дагестана.</p>
<p style="text-align:center">Так же, как и вы, мы &ndash; жители республики &ndash; заинтересованы в том, чтобы наше взаимодействие было мирным, продуктивным и способствовало как решению ваших целей, как стабильности и процветанию нашего региона.</p>
<p style="text-align:center">Для того, чтобы ваше общение с местными жителями было комфортным, важно знать местную культуру и обычаи: что принято, а что не приветствуется или воспринимается плохо. Ведь культура и обычаи жителей разных стран и даже регионов одной страны имеют сильные отличия.</p>
<p style="text-align:center">Дорогие гости, с помощью данного приложения мы хотим коротко и просто рассказать вам о самой республике, законах и правилах, по которым здесь живут люди, где и у кого искать помощь и совет, чтобы вы могли избежать неприятных жизненных ситуаций, связанных с незнанием законов <br>Российской Федерации.</p>
      """,),
          ),
          Positioned(
            right: 10, bottom: 10,
            child: SizedBox(
              width: 50,
                height: 50,
                child: ElevatedButton(
                  onPressed: (){setState((){showInfo = false;});},
                  style: ElevatedButton.styleFrom(shape: CircleBorder(), padding: EdgeInsets.zero),
                  child: Center(child: Icon(Icons.keyboard_arrow_right_outlined, color: Colors.white, size: 40,)),
                )),
          )
        ],
      ),
    ),
  );

  Widget buildOnBoarding(BuildContext context, bool isDisplay) {
    final WidgetConfig widgetConfig = widget.store.data.settings['general'].widgets['general'];
    bool enableOnBoarding = get(widgetConfig.fields, ['enableOnBoarding'], true);
    bool forceLogin = get(widgetConfig.fields, ['forceLogin'], false);

    if (isDisplay && enableOnBoarding) {
      return OnBoardingScreen(store: widget.store);
    }

    if (forceLogin && !_authStore.isLogin) {
      return LoginScreen(store: widget.store);
    }

    return buildHome(widget.store.data);
  }

  Widget buildHome(DataScreen data) {
    if (data == null) return Container();

    bool isRTL = (Directionality.of(context) == TextDirection.rtl);

    Map<String, Widget> _widgetOptions = {}..addAll(widgetOptions);

    Data tabsData = data.settings['tabs'];
    Data sidebarData = data.settings['sidebar'];
    Data homeData = data.screens['home'];

    // Home Configs
    bool extendBody = get(homeData.configs, ['extendBody'], true);

    // Add custom tabs
    Map<String, Data> extraScreens = data.extraScreens;
    extraScreens.forEach((key, value) {
      _widgetOptions.putIfAbsent("extraScreens_$key", () => CustomScreen(screenKey: key));
    });

    // Drawer
    String layout = sidebarData.widgets['sidebar'].layout;
    Color background = ConvertData.fromRGBA(
      get(sidebarData.widgets['sidebar'].styles, ['background', Provider.of<SettingStore>(context).themeModeKey]),
      Theme.of(context).canvasColor,
    );
    String scaleRotate = 'style2';
    String scaleBottom = 'style5';
    String scaleTop = 'style6';
    double angle = 0.0;
    double heightStyle = 0.0;

    double widthStyle = MediaQuery.of(context).size.width * (isRTL ? 0.65 : 0.83);
    if (scaleRotate == '$layout') {
      angle = -3.0;
    }
    if (scaleBottom == '$layout') {
      heightStyle = MediaQuery.of(context).size.height * (isRTL ? -0.19 : 0.19);
    }
    if (scaleTop == '$layout') {
      heightStyle = -MediaQuery.of(context).size.height * (isRTL ? -0.19 : 0.19);
    }
    String tabActive = widget.store.tab;
    Map<String, dynamic> types = {
      'default': StyleState.overlay,
      'style1': StyleState.scaleRight,
      'style2': StyleState.scaleRight,
      'style3': StyleState.stack,
      'style4': StyleState.fixedStack,
      'style5': StyleState.scaleRight,
      'style6': StyleState.scaleRight,
      'style7': StyleState.rotate3dIn,
      'style8': StyleState.rotate3dOut,
      'style9': StyleState.popUp,
    };

    return ZoomDrawer(
      isRTL: isRTL,
      type: types['$layout'],
      controller: _drawerController,
      slideWidth: widthStyle,
      slideHeight: heightStyle,
      borderRadius: 24.0,
      backgroundColor: background,
      menuScreen: Sidebar(
        data: sidebarData,
        categories: _categoryStore.categories,
      ),
      showShadow: true,
      // shadowColor: Theme.of(context).scaffoldBackgroundColor,
      mainScreen: Scaffold(
        key: _scaffoldKey,
        extendBody: extendBody,
        bottomNavigationBar: Tabs(
          selected: tabActive,
          onItemTapped: widget.store.setTab,
          data: tabsData,
        ),
        body: _widgetOptions[tabActive],
      ),
      angle: angle,
      // openCurve: Curves.fastOutSlowIn,
      // closeCurve: Curves.bounceIn,
    );
  }
}
