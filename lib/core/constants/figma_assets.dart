/// Raster assets exported from Figma MCP (file vf6Xx7NvM8GBGditNmCUqu).
abstract final class FigmaAssets {
  static const images = 'assets/images/';
  static const icons = 'assets/icons/';

  static const splashBgFood = '${images}splash_bg_food.png';
  static const splashLogoMain = '${images}splash_logo_main.png';
  static const splashBottomWave = '${images}splash_bottom_wave.png';
  static const loginBgFood = '${images}login_bg_food.png';
  static const loginHeaderWave = '${images}login_header_wave.png';
  static const loginHeroHouse = '${images}login_hero_house.png';
  static const onboardingEatingMan = '${images}onboarding_eating_man.png';
  static const profileHeaderWave = '${images}profile_header_wave.png';
  static const profileAvatarSample = '${images}profile_avatar_sample.png';

  static const globeWhite = '${icons}globe_white.png';
  static const chevronUpOrange = '${icons}chevron_up_orange.png';
  static const chevronDownWhite = '${icons}chevron_down_white.png';
  static const loginBackWhite = '${icons}login_back_white.png';
  static const loginUserGrey = '${icons}login_user_grey.png';
  static const loginPasswordGrey = '${icons}login_password_grey.png';
  static const facebookWhite = '${icons}facebook_white.png';
  static const googleWhite = '${icons}google_white.png';
  static const profileBackWhite = '${icons}profile_back_white.png';
  static const profileChevronOrange = '${icons}profile_chevron_orange.png';
  static const profileSettingsOrange = '${icons}profile_settings_orange.png';
  static const profileStarOrange = '${icons}profile_star_orange.png';
  static const profileOrders = '${icons}profile_orders.png';
  static const profileNotification = '${icons}profile_notification.png';
  static const profileLogout = '${icons}profile_logout.png';
  static const navMore = '${icons}nav_more.png';

  /// Figma MCP exports many vectors with a `.png` extension (SVG/XML body).
  static const svgAssets = {
    splashBottomWave,
    loginHeaderWave,
    profileHeaderWave,
    chevronUpOrange,
    chevronDownWhite,
    loginBackWhite,
    profileBackWhite,
    profileChevronOrange,
    profileSettingsOrange,
    profileStarOrange,
    profileOrders,
    profileNotification,
    profileLogout,
    navMore,
  };

  static bool isSvg(String path) => svgAssets.contains(path);
}
