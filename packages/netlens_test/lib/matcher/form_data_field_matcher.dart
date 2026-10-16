import 'package:netlens/model/netlens_from_data_field.dart';
import 'package:test/test.dart';

class FormDataFieldMatcher extends Matcher {
  final NetLensFormDataField _expected;

  const FormDataFieldMatcher(this._expected);

  @override
  bool matches(Object? item, Map matchState) {
    try {
      if (item is List<NetLensFormDataField>) {
        final formField = item.firstWhere(
          (element) => element.name == _expected.name,
        );
        return formField.value == _expected.value;
      }
    } catch (_) {}
    return false;
  }

  @override
  Description describe(Description description) =>
      description.add('contains form field').addDescriptionOf(_expected);

  @override
  Description describeMismatch(
    Object? item,
    Description mismatchDescription,
    Map matchState,
    bool verbose,
  ) {
    mismatchDescription
        .add('does not contain form field')
        .addDescriptionOf(_expected);
    return mismatchDescription;
  }
}
