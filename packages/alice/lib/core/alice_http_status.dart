/// Name and explanation of an HTTP status code.
typedef AliceHttpStatusInfo = ({String name, String description});

/// Category of an HTTP status code.
enum AliceHttpStatusCategory {
  informational,
  success,
  redirection,
  clientError,
  serverError,
  failed,
  unknown,
}

/// Explains HTTP status codes in supported languages. English is used when
/// language or code is not translated.
class AliceHttpStatus {
  AliceHttpStatus._();

  /// Returns category of [status].
  static AliceHttpStatusCategory getCategory(int? status) => switch (status) {
    -1 => AliceHttpStatusCategory.failed,
    int status when status >= 100 && status < 200 =>
      AliceHttpStatusCategory.informational,
    int status when status >= 200 && status < 300 =>
      AliceHttpStatusCategory.success,
    int status when status >= 300 && status < 400 =>
      AliceHttpStatusCategory.redirection,
    int status when status >= 400 && status < 500 =>
      AliceHttpStatusCategory.clientError,
    int status when status >= 500 && status < 600 =>
      AliceHttpStatusCategory.serverError,
    _ => AliceHttpStatusCategory.unknown,
  };

  /// Returns name and explanation of [status] for [languageCode], or null
  /// when the code is not known.
  static AliceHttpStatusInfo? get({
    required int? status,
    required String languageCode,
  }) {
    final Map<int, AliceHttpStatusInfo> localized =
        _values[languageCode] ?? _en;
    return localized[status] ?? _en[status];
  }

  static const Map<String, Map<int, AliceHttpStatusInfo>> _values = {
    'en': _en,
    'ar': _ar,
  };

  static const Map<int, AliceHttpStatusInfo> _en = {
    -1: (
      name: 'Request failed',
      description:
          'No response was received. The request failed before reaching the '
          'server or while waiting for it: no network connection, timeout, '
          'wrong host or port, invalid URL or a TLS error. Check the Error tab '
          'for details.',
    ),
    0: (
      name: 'Unknown',
      description: 'The response did not contain a status code.',
    ),
    100: (
      name: 'Continue',
      description:
          'The server received the request headers and the client should '
          'send the request body.',
    ),
    101: (
      name: 'Switching Protocols',
      description:
          'The server is switching protocols as requested by the client, for '
          'example to WebSocket.',
    ),
    102: (
      name: 'Processing',
      description:
          'The server accepted the request but has not completed it yet.',
    ),
    103: (
      name: 'Early Hints',
      description:
          'The server sends some headers before the final response so the '
          'client can start preloading resources.',
    ),
    200: (name: 'OK', description: 'The request succeeded.'),
    201: (
      name: 'Created',
      description:
          'The request succeeded and a new resource was created, usually '
          'after a POST or PUT.',
    ),
    202: (
      name: 'Accepted',
      description:
          'The request was accepted for processing, but processing has not '
          'finished yet.',
    ),
    203: (
      name: 'Non-Authoritative Information',
      description:
          'The request succeeded, but the returned data was modified by a '
          'proxy.',
    ),
    204: (
      name: 'No Content',
      description:
          'The request succeeded and there is no content in the response '
          'body.',
    ),
    205: (
      name: 'Reset Content',
      description:
          'The request succeeded and the client should reset the form or '
          'view that sent it.',
    ),
    206: (
      name: 'Partial Content',
      description:
          'The server returned only the part of the resource requested with '
          'the Range header.',
    ),
    300: (
      name: 'Multiple Choices',
      description:
          'The request has more than one possible response and the client '
          'should choose one.',
    ),
    301: (
      name: 'Moved Permanently',
      description:
          'The resource has a new permanent URL, given in the Location '
          'header. Update the URL in your app.',
    ),
    302: (
      name: 'Found',
      description:
          'The resource is temporarily at a different URL, given in the '
          'Location header.',
    ),
    303: (
      name: 'See Other',
      description:
          'The response can be found at another URL using a GET request.',
    ),
    304: (
      name: 'Not Modified',
      description:
          'The resource has not changed since the cached version, so the '
          'client can use its cache.',
    ),
    307: (
      name: 'Temporary Redirect',
      description:
          'The resource is temporarily at another URL. Repeat the request '
          'there with the same method and body.',
    ),
    308: (
      name: 'Permanent Redirect',
      description:
          'The resource has a new permanent URL. Repeat the request there '
          'with the same method and body.',
    ),
    400: (
      name: 'Bad Request',
      description:
          'The server could not understand the request: malformed syntax, '
          'invalid parameters or an invalid body. Check the request body and '
          'query parameters.',
    ),
    401: (
      name: 'Unauthorized',
      description:
          'Authentication is required or has failed. Check the token or '
          'credentials in the Authorization header.',
    ),
    402: (
      name: 'Payment Required',
      description: 'Payment is required to access this resource.',
    ),
    403: (
      name: 'Forbidden',
      description:
          'The server understood the request but refuses it. The user is '
          'authenticated but does not have permission.',
    ),
    404: (
      name: 'Not Found',
      description:
          'The server cannot find the requested resource. Check the endpoint '
          'path and IDs in the URL.',
    ),
    405: (
      name: 'Method Not Allowed',
      description:
          'The HTTP method is not supported for this endpoint, for example '
          'POST on a GET-only endpoint.',
    ),
    406: (
      name: 'Not Acceptable',
      description:
          'The server cannot return a response matching the Accept headers '
          'of the request.',
    ),
    408: (
      name: 'Request Timeout',
      description:
          'The server timed out waiting for the request. Try sending it '
          'again.',
    ),
    409: (
      name: 'Conflict',
      description:
          'The request conflicts with the current state of the resource, '
          'for example a duplicate entry or a version conflict.',
    ),
    410: (
      name: 'Gone',
      description:
          'The resource was permanently removed and is no longer available.',
    ),
    411: (
      name: 'Length Required',
      description: 'The server requires a Content-Length header.',
    ),
    412: (
      name: 'Precondition Failed',
      description: 'A precondition in the request headers was not met.',
    ),
    413: (
      name: 'Content Too Large',
      description:
          'The request body is larger than the server allows, for example '
          'an uploaded file that is too big.',
    ),
    414: (
      name: 'URI Too Long',
      description: 'The URL is longer than the server is willing to handle.',
    ),
    415: (
      name: 'Unsupported Media Type',
      description:
          'The server does not support the format of the request body. '
          'Check the Content-Type header.',
    ),
    416: (
      name: 'Range Not Satisfiable',
      description: 'The range in the Range header cannot be served.',
    ),
    417: (
      name: 'Expectation Failed',
      description: 'The server cannot meet the Expect request header.',
    ),
    418: (
      name: "I'm a teapot",
      description: 'The server refuses to brew coffee because it is a teapot.',
    ),
    422: (
      name: 'Unprocessable Content',
      description:
          'The request is well formed but contains invalid data, usually '
          'validation errors. Check the response body for details.',
    ),
    423: (name: 'Locked', description: 'The resource is locked.'),
    425: (
      name: 'Too Early',
      description:
          'The server is unwilling to process a request that might be '
          'replayed.',
    ),
    426: (
      name: 'Upgrade Required',
      description: 'The client should switch to a different protocol.',
    ),
    428: (
      name: 'Precondition Required',
      description: 'The server requires the request to be conditional.',
    ),
    429: (
      name: 'Too Many Requests',
      description:
          'Too many requests were sent in a short time (rate limiting). Wait '
          'before retrying; see the Retry-After header if present.',
    ),
    431: (
      name: 'Request Header Fields Too Large',
      description: 'The request headers are too large.',
    ),
    451: (
      name: 'Unavailable For Legal Reasons',
      description: 'The resource cannot be provided for legal reasons.',
    ),
    500: (
      name: 'Internal Server Error',
      description:
          'The server hit an unexpected error. This is a server-side '
          'problem; check the server logs.',
    ),
    501: (
      name: 'Not Implemented',
      description: 'The server does not support this functionality.',
    ),
    502: (
      name: 'Bad Gateway',
      description:
          'A gateway or proxy received an invalid response from the upstream '
          'server.',
    ),
    503: (
      name: 'Service Unavailable',
      description:
          'The server is temporarily unable to handle the request, usually '
          'due to maintenance or overload.',
    ),
    504: (
      name: 'Gateway Timeout',
      description:
          'A gateway or proxy did not get a response from the upstream '
          'server in time.',
    ),
    505: (
      name: 'HTTP Version Not Supported',
      description:
          'The server does not support the HTTP version used in the request.',
    ),
    507: (
      name: 'Insufficient Storage',
      description:
          'The server does not have enough storage to complete the request.',
    ),
    511: (
      name: 'Network Authentication Required',
      description:
          'The client must authenticate to gain network access, for example '
          'on a captive portal.',
    ),
  };

  static const Map<int, AliceHttpStatusInfo> _ar = {
    -1: (
      name: 'فشل الطلب',
      description:
          'لم يتم استلام أي استجابة. فشل الطلب قبل الوصول إلى الخادم أو أثناء '
          'انتظاره: لا يوجد اتصال بالشبكة، أو انتهت المهلة، أو المضيف أو المنفذ '
          'خاطئ، أو الرابط غير صالح، أو خطأ في TLS. راجع تبويب الخطأ للتفاصيل.',
    ),
    0: (name: 'غير معروف', description: 'لم تتضمن الاستجابة رمز حالة.'),
    100: (
      name: 'متابعة',
      description: 'استلم الخادم ترويسات الطلب، وعلى العميل إرسال محتوى الطلب.',
    ),
    101: (
      name: 'تبديل البروتوكول',
      description:
          'يقوم الخادم بتبديل البروتوكول بناءً على طلب العميل، مثل WebSocket.',
    ),
    102: (
      name: 'قيد المعالجة',
      description: 'قبل الخادم الطلب لكنه لم يكمله بعد.',
    ),
    103: (
      name: 'تلميحات مبكرة',
      description:
          'يرسل الخادم بعض الترويسات قبل الاستجابة النهائية ليبدأ العميل '
          'بتحميل الموارد مسبقاً.',
    ),
    200: (name: 'تم بنجاح', description: 'نجح الطلب.'),
    201: (
      name: 'تم الإنشاء',
      description: 'نجح الطلب وتم إنشاء مورد جديد، عادةً بعد POST أو PUT.',
    ),
    202: (
      name: 'تم القبول',
      description: 'تم قبول الطلب للمعالجة لكن المعالجة لم تنتهِ بعد.',
    ),
    203: (
      name: 'معلومات غير موثوقة',
      description: 'نجح الطلب لكن البيانات المرجعة عُدّلت بواسطة وسيط (proxy).',
    ),
    204: (
      name: 'لا يوجد محتوى',
      description: 'نجح الطلب ولا يوجد محتوى في جسم الاستجابة.',
    ),
    205: (
      name: 'إعادة تعيين المحتوى',
      description: 'نجح الطلب وعلى العميل إعادة تعيين النموذج أو الواجهة.',
    ),
    206: (
      name: 'محتوى جزئي',
      description: 'أعاد الخادم الجزء المطلوب فقط من المورد عبر ترويسة Range.',
    ),
    300: (
      name: 'خيارات متعددة',
      description: 'للطلب أكثر من استجابة ممكنة وعلى العميل اختيار إحداها.',
    ),
    301: (
      name: 'نُقل نهائياً',
      description:
          'للمورد رابط دائم جديد موجود في ترويسة Location. حدّث الرابط في '
          'تطبيقك.',
    ),
    302: (
      name: 'تم العثور عليه',
      description: 'المورد موجود مؤقتاً في رابط آخر موجود في ترويسة Location.',
    ),
    303: (
      name: 'انظر مكاناً آخر',
      description: 'يمكن الحصول على الاستجابة من رابط آخر باستخدام طلب GET.',
    ),
    304: (
      name: 'لم يتغير',
      description:
          'لم يتغير المورد منذ النسخة المخزنة، ويمكن للعميل استخدامها.',
    ),
    307: (
      name: 'إعادة توجيه مؤقتة',
      description:
          'المورد مؤقتاً في رابط آخر. أعد الطلب هناك بنفس الطريقة والمحتوى.',
    ),
    308: (
      name: 'إعادة توجيه دائمة',
      description:
          'للمورد رابط دائم جديد. أعد الطلب هناك بنفس الطريقة والمحتوى.',
    ),
    400: (
      name: 'طلب غير صالح',
      description:
          'لم يتمكن الخادم من فهم الطلب: صيغة خاطئة أو معاملات أو محتوى غير '
          'صالح. تحقق من جسم الطلب ومعاملات الاستعلام.',
    ),
    401: (
      name: 'غير مصرح',
      description:
          'المصادقة مطلوبة أو فشلت. تحقق من الرمز أو بيانات الدخول في ترويسة '
          'Authorization.',
    ),
    402: (
      name: 'الدفع مطلوب',
      description: 'يلزم الدفع للوصول إلى هذا المورد.',
    ),
    403: (
      name: 'ممنوع',
      description:
          'فهم الخادم الطلب لكنه يرفضه. المستخدم مسجّل الدخول لكن ليست لديه '
          'صلاحية.',
    ),
    404: (
      name: 'غير موجود',
      description:
          'لا يجد الخادم المورد المطلوب. تحقق من مسار نقطة النهاية والمعرّفات '
          'في الرابط.',
    ),
    405: (
      name: 'الطريقة غير مسموحة',
      description:
          'طريقة HTTP غير مدعومة لهذه النقطة، مثل POST على نقطة تقبل GET فقط.',
    ),
    406: (
      name: 'غير مقبول',
      description: 'لا يستطيع الخادم إرجاع استجابة تطابق ترويسات Accept.',
    ),
    408: (
      name: 'انتهت مهلة الطلب',
      description: 'انتهت مهلة الخادم أثناء انتظار الطلب. حاول إرساله مجدداً.',
    ),
    409: (
      name: 'تعارض',
      description:
          'يتعارض الطلب مع الحالة الحالية للمورد، مثل إدخال مكرر أو تعارض '
          'في الإصدار.',
    ),
    410: (
      name: 'لم يعد متاحاً',
      description: 'تمت إزالة المورد نهائياً ولم يعد متاحاً.',
    ),
    411: (
      name: 'الطول مطلوب',
      description: 'يتطلب الخادم ترويسة Content-Length.',
    ),
    412: (
      name: 'فشل الشرط المسبق',
      description: 'لم يتحقق شرط مسبق في ترويسات الطلب.',
    ),
    413: (
      name: 'المحتوى كبير جداً',
      description:
          'جسم الطلب أكبر مما يسمح به الخادم، مثل ملف مرفوع كبير جداً.',
    ),
    414: (
      name: 'الرابط طويل جداً',
      description: 'الرابط أطول مما يقبل الخادم معالجته.',
    ),
    415: (
      name: 'نوع وسائط غير مدعوم',
      description:
          'لا يدعم الخادم صيغة جسم الطلب. تحقق من ترويسة Content-Type.',
    ),
    416: (
      name: 'النطاق غير قابل للتلبية',
      description: 'لا يمكن تلبية النطاق المحدد في ترويسة Range.',
    ),
    417: (
      name: 'فشل التوقع',
      description: 'لا يستطيع الخادم تلبية ترويسة Expect.',
    ),
    418: (
      name: 'أنا إبريق شاي',
      description: 'يرفض الخادم تحضير القهوة لأنه إبريق شاي.',
    ),
    422: (
      name: 'محتوى غير قابل للمعالجة',
      description:
          'صيغة الطلب صحيحة لكن البيانات غير صالحة، غالباً أخطاء تحقق. راجع '
          'جسم الاستجابة للتفاصيل.',
    ),
    423: (name: 'مقفل', description: 'المورد مقفل.'),
    425: (
      name: 'مبكر جداً',
      description: 'لا يرغب الخادم في معالجة طلب قد تتم إعادته.',
    ),
    426: (
      name: 'الترقية مطلوبة',
      description: 'على العميل التبديل إلى بروتوكول مختلف.',
    ),
    428: (
      name: 'الشرط المسبق مطلوب',
      description: 'يتطلب الخادم أن يكون الطلب مشروطاً.',
    ),
    429: (
      name: 'طلبات كثيرة جداً',
      description:
          'تم إرسال طلبات كثيرة في وقت قصير (تحديد المعدل). انتظر قبل إعادة '
          'المحاولة، وراجع ترويسة Retry-After إن وُجدت.',
    ),
    431: (
      name: 'ترويسات الطلب كبيرة جداً',
      description: 'ترويسات الطلب كبيرة جداً.',
    ),
    451: (
      name: 'غير متاح لأسباب قانونية',
      description: 'لا يمكن تقديم المورد لأسباب قانونية.',
    ),
    500: (
      name: 'خطأ داخلي في الخادم',
      description:
          'واجه الخادم خطأً غير متوقع. المشكلة من جهة الخادم؛ راجع سجلات '
          'الخادم.',
    ),
    501: (name: 'غير مُنفّذ', description: 'لا يدعم الخادم هذه الوظيفة.'),
    502: (
      name: 'بوابة غير صالحة',
      description: 'تلقت البوابة أو الوسيط استجابة غير صالحة من الخادم الأصلي.',
    ),
    503: (
      name: 'الخدمة غير متاحة',
      description:
          'الخادم غير قادر مؤقتاً على معالجة الطلب، غالباً بسبب الصيانة أو '
          'الضغط.',
    ),
    504: (
      name: 'انتهت مهلة البوابة',
      description:
          'لم تتلقَّ البوابة أو الوسيط استجابة من الخادم الأصلي في الوقت المحدد.',
    ),
    505: (
      name: 'إصدار HTTP غير مدعوم',
      description: 'لا يدعم الخادم إصدار HTTP المستخدم في الطلب.',
    ),
    507: (
      name: 'مساحة تخزين غير كافية',
      description: 'لا يملك الخادم مساحة كافية لإكمال الطلب.',
    ),
    511: (
      name: 'مصادقة الشبكة مطلوبة',
      description:
          'على العميل المصادقة للوصول إلى الشبكة، مثل صفحة تسجيل دخول شبكة '
          'عامة.',
    ),
  };
}
