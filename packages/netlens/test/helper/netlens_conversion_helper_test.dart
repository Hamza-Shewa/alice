import 'package:netlens/helper/netlens_conversion_helper.dart';
import 'package:test/test.dart';

void main() {
  group("NetLensConversionHelper", () {
    test("should format bytes", () {
      expect(NetLensConversionHelper.formatBytes(-100), "-1 B");
      expect(NetLensConversionHelper.formatBytes(0), "0 B");
      expect(NetLensConversionHelper.formatBytes(100), "100 B");
      expect(NetLensConversionHelper.formatBytes(999), "999 B");
      expect(NetLensConversionHelper.formatBytes(1000), "1000 B");
      expect(NetLensConversionHelper.formatBytes(1001), "1.00 kB");
      expect(NetLensConversionHelper.formatBytes(100000), "100.00 kB");
      expect(NetLensConversionHelper.formatBytes(1000000), "1000.00 kB");
      expect(NetLensConversionHelper.formatBytes(1000001), "1.00 MB");
      expect(NetLensConversionHelper.formatBytes(100000000), "100.00 MB");
    });

    test("should format time", () {
      expect(NetLensConversionHelper.formatTime(-100), "-1 ms");
      expect(NetLensConversionHelper.formatTime(0), "0 ms");
      expect(NetLensConversionHelper.formatTime(100), "100 ms");
      expect(NetLensConversionHelper.formatTime(1000), "1000 ms");
      expect(NetLensConversionHelper.formatTime(1001), "1.00 s");
      expect(NetLensConversionHelper.formatTime(5000), "5.00 s");
      expect(NetLensConversionHelper.formatTime(60000), "60.00 s");
      expect(NetLensConversionHelper.formatTime(60001), "1 min 0 s 1 ms");
      expect(NetLensConversionHelper.formatTime(85000), "1 min 25 s 0 ms");
    });

    test("should format clock time and date time", () {
      final time = DateTime(2026, 3, 7, 9, 5, 4, 42);
      expect(NetLensConversionHelper.formatClockTime(time), "09:05:04.042");
      expect(
        NetLensConversionHelper.formatDateTime(time),
        "2026-03-07 09:05:04.042",
      );
    });
  });
}
