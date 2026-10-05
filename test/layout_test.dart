import 'package:afterword/theme/layout.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('hero scale is 1.0 on iPhones', (tester) async {
    late Fit fit;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(390, 844),
          padding: EdgeInsets.only(top: 47, bottom: 34),
        ),
        child: Builder(
          builder: (context) {
            fit = Fit.of(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    expect(fit.heroScale, 1.0);
    expect(fit.bottomInset, 34);
  });

  testWidgets('hero scale grows on a tall phone and is capped', (tester) async {
    Future<Fit> fitFor(Size size, EdgeInsets padding) async {
      late Fit fit;
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(size: size, padding: padding),
          child: Builder(
            builder: (context) {
              fit = Fit.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      return fit;
    }

    final android = await fitFor(
      const Size(411, 914),
      const EdgeInsets.only(top: 24, bottom: 24),
    );
    expect(android.heroScale, closeTo(866 / Fit.baseHeight, 0.001));
    expect(android.hero(150), greaterThan(150));

    final huge = await fitFor(const Size(411, 1400), EdgeInsets.zero);
    expect(huge.heroScale, 1.25);
  });

  test('outline snaps to whole device pixels', () {
    addTearDown(() => PixelGrid.init(3));
    PixelGrid.init(3);
    expect(PixelGrid.outline, 3);
    PixelGrid.init(2.625);
    expect(PixelGrid.outline * 2.625, closeTo(8, 1e-9));
  });
}
