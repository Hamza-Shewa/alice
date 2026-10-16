import 'package:netlens/model/netlens_form_data_file.dart';
import 'package:test/test.dart';

class FormDataFileMatcher extends Matcher {
  final NetLensFormDataFile _expected;

  const FormDataFileMatcher(this._expected);

  @override
  bool matches(Object? item, Map matchState) {
    try {
      if (item is List<NetLensFormDataFile>) {
        final formFile = item.firstWhere(
          (element) => element.fileName == _expected.fileName,
        );
        return formFile.contentType == _expected.contentType;
      }
    } catch (_) {}
    return false;
  }

  @override
  Description describe(Description description) =>
      description.add('contains form file').addDescriptionOf(_expected);

  @override
  Description describeMismatch(
    Object? item,
    Description mismatchDescription,
    Map matchState,
    bool verbose,
  ) {
    mismatchDescription
        .add('does not contain form file')
        .addDescriptionOf(_expected);
    return mismatchDescription;
  }
}
