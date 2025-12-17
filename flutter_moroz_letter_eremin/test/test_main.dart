import 'models/letter_model_test.dart' as letter_model_test;
import 'models/delivery_status_test.dart' as delivery_status_test;
import 'services/letter_service_test.dart' as letter_service_test;
import 'services/parent_auth_service_test.dart' as parent_auth_test;
import 'widgets/home_screen_test.dart' as home_screen_test;

void main() {
  letter_model_test.main();
  delivery_status_test.main();
  letter_service_test.main();
  parent_auth_test.main();
  home_screen_test.main();
}
