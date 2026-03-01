import 'package:uni_tech/providers/auth_provider.dart';
import 'package:uni_tech/screens/auth/login_screen.dart';
import 'package:uni_tech/screens/categories/categories_index_screen.dart';
import 'package:uni_tech/screens/categories/category_profile_screen.dart';
import 'package:uni_tech/screens/users/add_user_screen.dart';
import 'package:uni_tech/screens/users/edit_user_screen.dart';
import 'package:uni_tech/screens/users/user_detail_screen.dart';
import 'package:uni_tech/screens/users/user_profile_screen.dart';
import 'package:uni_tech/screens/users/users_index_screen.dart';
import 'package:web/web.dart' as web;
import 'package:uni_tech/models/Category.dart';
import 'package:uni_tech/models/Product.dart';
import 'package:uni_tech/models/User.dart';
import 'package:uni_tech/screens/products/add_product_screen.dart';
import 'package:uni_tech/screens/products/product_detail_screen.dart';
import 'package:uni_tech/screens/products/edit_product_screen.dart';
import 'package:uni_tech/screens/shop/shop_cart_screen.dart';
import 'package:uni_tech/screens/shop/checkout_screen.dart';
import 'package:uni_tech/screens/shop/shop_home_screen.dart';
import 'package:uni_tech/screens/shop/signup_screen.dart';
import 'package:uni_tech/screens/shop/my_orders_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

// Import your screens
import 'package:uni_tech/screens/products/products_index_screen.dart';
import 'package:uni_tech/screens/dashboard_screen.dart';

void changeWebUrl(String route) {
  String destination = route;
  if (route == "/logout") {
    destination = '/login';
  }
  web.window.history.pushState(null, '', destination);
}

void setScreenAsUrl(WidgetRef ref) async {
  ref.read(navigationProvider.notifier).setLoading(true);

  final String? accessToken = web.window.localStorage.getItem("token");
  if (accessToken != null) {
    final User? user = await authencateUser(decryptToken(accessToken));
    if (user != null) {
      ref.read(authProvider.notifier).setAuth(user);
    }
  }

  String url = web.window.location.pathname;

  if (url == '/' || url.isEmpty) {
    await ref.read(navigationProvider.notifier).setScreen(AppRoutes.shopHome);
    ref.read(navigationProvider.notifier).setLoading(false);
    return;
  }

  for (var entry in titles.entries) {
    String pattern = entry.value["route"]!;
    String baseRoute = pattern.replaceAll("{id}", "");

    if (url.startsWith(baseRoute)) {
      // Dynamic route?
      if (pattern.contains("{id}")) {
        String id = url.substring(baseRoute.length);

        // Only call ONCE
        await ref.read(navigationProvider.notifier).setScreen(entry.key, id);

        ref.read(navigationProvider.notifier).setLoading(false);
        return;
      }

      // Static route
      await ref.read(navigationProvider.notifier).setScreen(entry.key);
      ref.read(navigationProvider.notifier).setLoading(false);
      return;
    }
  }

  ref.read(navigationProvider.notifier).setScreen(AppRoutes.shopHome);
}

enum AppRoutes {
  shopHome,
  shopCart,
  shopCheckout,
  signup,

  login,
  logout,
  myProfile,
  myOrders,
  dashboard,

  usersIndex,
  usersDetails,
  usersEdit,
  usersCreate,

  productsIndex,
  productsDetails,
  productsEdit,
  productsCreate,

  ordersIndex,
  ordersDetails,
  ordersEdit,
  ordersCreate,

  categoriesIndex,
  categoriesDetails,
  categoriesEdit,
  categoriesCreate,
}

Map<AppRoutes, Map<String, String>> titles = {
  AppRoutes.shopHome: {
    "title": "Shop",
    "is_authencated": "NO",
    "is_admin_route": "NO",
    "route": "/shop",
  },
  AppRoutes.shopCart: {
    "title": "Cart",
    "is_authencated": "NO",
    "is_admin_route": "NO",
    "route": "/shop/cart",
  },
  AppRoutes.shopCheckout: {
    "title": "Checkout",
    "is_authencated": "YES",
    "is_admin_route": "NO",
    "route": "/shop/checkout",
  },
  AppRoutes.signup: {
    "title": "Sign Up",
    "is_authencated": "NO",
    "is_admin_route": "NO",
    "route": "/signup",
  },
  AppRoutes.dashboard: {
    "title": "Dashboard",
    "is_authencated": "YES",
    "is_admin_route": "YES",
    "route": "/dashboard",
  },
  AppRoutes.myProfile: {
    "title": "My Profile",
    "is_authencated": "YES",
    "is_admin_route": "NO",
    "route": "/my-profile",
  },
  AppRoutes.myOrders: {
    "title": "My Orders",
    "is_authencated": "YES",
    "is_admin_route": "NO",
    "route": "/my-orders",
  },
  AppRoutes.login: {
    "title": "Login",
    "is_authencated": "NO",
    "is_admin_route": "NO",
    "route": "/login",
  },
  AppRoutes.logout: {
    "title": "Logout",
    "is_authencated": "NO",
    "is_admin_route": "NO",
    "route": "/logout",
  },

  AppRoutes.usersIndex: {
    "title": "All Users",
    "is_authencated": "YES",
    "is_admin_route": "YES",
    "route": "/users/list",
  },
  AppRoutes.usersDetails: {
    "title": "User Details",
    "is_authencated": "YES",
    "is_admin_route": "YES",
    "route": "/users/details/{id}",
  },
  AppRoutes.usersEdit: {
    "title": "Edit User",
    "is_authencated": "YES",
    "is_admin_route": "NO",
    "route": "/users/edit/{id}",
  },
  AppRoutes.usersCreate: {
    "title": "Create User",
    "is_authencated": "YES",
    "is_admin_route": "YES",
    "route": "/users/create",
  },

  AppRoutes.productsIndex: {
    "title": "All Products",
    "is_authencated": "YES",
    "is_admin_route": "NO",
    "route": "/products/list",
  },
  AppRoutes.productsDetails: {
    "title": "Product Details",
    "is_authencated": "YES",
    "is_admin_route": "NO",
    "route": "/products/details/{id}",
  },
  AppRoutes.productsEdit: {
    "title": "Edit Product",
    "is_authencated": "YES",
    "is_admin_route": "YES",
    "route": "/products/edit/{id}",
  },
  AppRoutes.productsCreate: {
    "title": "Create Product",
    "is_authencated": "YES",
    "is_admin_route": "YES",
    "route": "/products/create",
  },

  AppRoutes.ordersIndex: {
    "title": "All Orders",
    "is_authencated": "YES",
    "is_admin_route": "YES",
    "route": "/orders/list",
  },
  AppRoutes.ordersDetails: {
    "title": "Order Details",
    "is_authencated": "YES",
    "is_admin_route": "YES",
    "route": "/orders/details/{id}",
  },
  AppRoutes.ordersEdit: {
    "title": "Edit Order",
    "is_authencated": "YES",
    "is_admin_route": "YES",
    "route": "/orders/edit/{id}",
  },
  AppRoutes.ordersCreate: {
    "title": "Create Order",
    "is_authencated": "YES",
    "is_admin_route": "YES",
    "route": "/orders/create",
  },

  AppRoutes.categoriesIndex: {
    "title": "All Categories",
    "is_authencated": "YES",
    "is_admin_route": "YES",
    "route": "/categories/list",
  },
  AppRoutes.categoriesDetails: {
    "title": "Category Details",
    "is_authencated": "YES",
    "is_admin_route": "YES",
    "route": "/categories/details/{id}",
  },
  AppRoutes.categoriesEdit: {
    "title": "Edit Category",
    "is_authencated": "YES",
    "is_admin_route": "YES",
    "route": "/categories/edit/{id}",
  },
  AppRoutes.categoriesCreate: {
    "title": "Create Category",
    "is_authencated": "YES",
    "is_admin_route": "YES",
    "route": "/categories/create",
  },
};

// Navigation State
class NavigationState {
  final AppRoutes screen;
  final String title;
  final Widget widget;
  final bool loading;

  NavigationState({
    required this.screen,
    required this.title,
    required this.widget,
    required this.loading,
  });
}

// Navigation Notifier
class NavigationNotifier extends StateNotifier<NavigationState> {
  final Ref ref;

  NavigationNotifier(this.ref)
    : super(
        NavigationState(
          screen: AppRoutes.shopHome,
          title: titles[AppRoutes.shopHome]!['title']!,
          widget: ShopHomeScreen(),
          loading: true,
        ),
      );

  void setLoading(bool value) {
    state = NavigationState(
      screen: state.screen,
      title: state.title,
      widget: state.widget,
      loading: value,
    );
  }

  Future<void> setScreen(AppRoutes screen, [String? id]) async {
    Widget newWidget;
    bool requiresAuth = titles[screen]!["is_authencated"]! == "YES";
    bool adminScreen = titles[screen]!["is_admin_route"]! == "YES";
    final authUser = ref.read(authProvider.notifier).getAuth();

    if (adminScreen && (authUser == null || authUser.role.name != 'admin')) {
      if (authUser == null) {
        newWidget = LoginScreen();
      } else {
        newWidget = UserProfileScreen(user: authUser);
        changeWebUrl(_routeToUrl(AppRoutes.myProfile, authUser.id));
      }
    } else if (requiresAuth && authUser == null) {
      newWidget = LoginScreen();
      changeWebUrl(_routeToUrl(AppRoutes.login, null));
    } else {
      switch (screen) {
        case AppRoutes.shopHome:
          newWidget = const ShopHomeScreen();
          break;
        case AppRoutes.shopCart:
          newWidget = ShopCartScreen();
          break;
        case AppRoutes.shopCheckout:
          newWidget = const CheckoutScreen();
          break;
        case AppRoutes.signup:
          newWidget = const SignupScreen();
          break;
        case AppRoutes.login:
          newWidget = LoginScreen();
          break;
        case AppRoutes.logout:
          ref.read(authProvider.notifier).clearAuth();
          newWidget = LoginScreen();
          break;
        case AppRoutes.myProfile:
          User? user = ref.read(authProvider.notifier).getAuth();
          if (user == null) {
            ref.read(navigationProvider.notifier).setScreen(AppRoutes.login);
          }
          newWidget = UserProfileScreen(user: user!);
          break;
        case AppRoutes.myOrders:
          newWidget = const MyOrdersScreen();
          break;
        case AppRoutes.dashboard:
          newWidget = DashboardScreen();
          break;
        case AppRoutes.usersIndex:
          newWidget = UsersIndexScreen();
          break;
        case AppRoutes.usersDetails:
          if (id == null || id.isEmpty) {
            newWidget = UsersIndexScreen();
            break;
          }
          final User? detailUser = await getUserById(id);
          if (detailUser == null) {
            newWidget = UsersIndexScreen();
            break;
          }
          newWidget = UserDetailScreen(user: detailUser);
          break;
        case AppRoutes.usersEdit:
          User? user = authUser;
          if ((id != null && id != authUser!.id) &&
              authUser.role.name == "admin") {
            user = await getUserById(id);
          } else {
            id = authUser!.id;
          }
          newWidget = EditUserScreen(user: user!);
          break;
        case AppRoutes.usersCreate:
          newWidget = AddUserScreen();
          break;
        case AppRoutes.categoriesIndex:
          newWidget = CategoriesIndexScreen();
          break;
        case AppRoutes.categoriesDetails:
          final Category? category = await getCategoryById(id!);
          newWidget = CategoryProfileScreen(category: category!);
          break;
        case AppRoutes.productsIndex:
          newWidget = ProductsIndexScreen();
          break;
        case AppRoutes.productsCreate:
          newWidget = AddProductScreen();
          break;
        case AppRoutes.productsEdit:
          final Product? product = await getProductById(id!);
          newWidget = EditProductScreen(product: product!);
          break;
        case AppRoutes.productsDetails:
          final Product? product = await getProductById(id!);
          final Category? category = await getCategoryById(product!.categoryId);
          newWidget = DetailProductScreen(product: product, category: category);
          break;
        default:
          newWidget = DashboardScreen();
          break;
      }
      changeWebUrl(_routeToUrl(screen, id));
    }

    state = NavigationState(
      screen: screen,
      title: titles[screen]!["title"]!,
      widget: newWidget,
      loading: false,
    );
  }
}

String _routeToUrl(AppRoutes route, String? id) {
  String raw = titles[route]!["route"]!;
  if (id != null) raw = raw.replaceAll("{id}", id);
  return raw;
}

final navigationProvider =
    StateNotifierProvider<NavigationNotifier, NavigationState>((ref) {
      return NavigationNotifier(ref);
    });
