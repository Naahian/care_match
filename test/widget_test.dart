import 'package:care_match/features/doctors/presentation/screens/doctor_search_screen.dart';
import 'package:care_match/main.dart';
import 'package:care_match/router.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

void main() {
  testWidgets('App starts on the doctors route', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    final router = createAppRouter();
    addTearDown(router.dispose);
    await tester.pumpWidget(Sizer(builder: (_, _, _) => MyApp(router: router)));
    await tester.pumpAndSettle();
    expect(find.byType(FindDoctorScreen), findsOneWidget);
    expect(router.routeInformationProvider.value.uri.path, '/doctors');
  });
}
