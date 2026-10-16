import 'package:alice/model/alice_translation.dart';

/// Class used to manage translations in Alice.
class AliceTranslations {
  /// Contains list of translation data for all languages.
  static final List<AliceTranslationData> _translations = _initialise();

  /// Initialises translation data for all languages.
  static List<AliceTranslationData> _initialise() {
    List<AliceTranslationData> translations = [];
    translations.add(_buildEnTranslations());
    translations.add(_buildArTranslations());
    return translations;
  }

  /// Builds [AliceTranslationData] for english language.
  static AliceTranslationData _buildEnTranslations() {
    return AliceTranslationData(
      languageCode: "en",
      values: {
        AliceTranslationKey.alice: "Alice",
        AliceTranslationKey.callDetails: "HTTP Call Details",
        AliceTranslationKey.emailSubject: "Alice report",
        AliceTranslationKey.callDetailsRequest: "Request",
        AliceTranslationKey.callDetailsResponse: "Response",
        AliceTranslationKey.callDetailsOverview: "Overview",
        AliceTranslationKey.callDetailsError: "Error",
        AliceTranslationKey.callDetailsEmpty: "Loading data failed",
        AliceTranslationKey.callErrorScreenErrorEmpty: "Error is empty",
        AliceTranslationKey.callErrorScreenError: "Error:",
        AliceTranslationKey.callErrorScreenStacktrace: "Stack trace:",
        AliceTranslationKey.callErrorScreenEmpty: "Nothing to display here",
        AliceTranslationKey.callOverviewMethod: "Method:",
        AliceTranslationKey.callOverviewServer: "Server:",
        AliceTranslationKey.callOverviewEndpoint: "Endpoint:",
        AliceTranslationKey.callOverviewStarted: "Started:",
        AliceTranslationKey.callOverviewFinished: "Finished:",
        AliceTranslationKey.callOverviewDuration: "Duration:",
        AliceTranslationKey.callOverviewBytesSent: "Bytes sent:",
        AliceTranslationKey.callOverviewBytesReceived: "Bytes received:",
        AliceTranslationKey.callOverviewClient: "Client:",
        AliceTranslationKey.callOverviewSecure: "Secure:",
        AliceTranslationKey.callRequestStarted: "Started:",
        AliceTranslationKey.callRequestBytesSent: "Bytes sent:",
        AliceTranslationKey.callRequestContentType: "Content type:",
        AliceTranslationKey.callRequestBody: "Body:",
        AliceTranslationKey.callRequestBodyEmpty: "Body is empty",
        AliceTranslationKey.callRequestFormDataFields: "Form data fields:",
        AliceTranslationKey.callRequestFormDataFiles: "Form files:",
        AliceTranslationKey.callRequestHeaders: "Headers:",
        AliceTranslationKey.callRequestHeadersEmpty: "Headers are empty",
        AliceTranslationKey.callRequestQueryParameters: "Query parameters",
        AliceTranslationKey.callRequestQueryParametersEmpty:
            "Query parameters are empty",
        AliceTranslationKey.callResponseWaitingForResponse:
            "Awaiting response...",
        AliceTranslationKey.callResponseError: "Error",
        AliceTranslationKey.callResponseReceived: "Received:",
        AliceTranslationKey.callResponseBytesReceived: "Bytes received:",
        AliceTranslationKey.callResponseStatus: "Status:",
        AliceTranslationKey.callResponseHeaders: "Headers:",
        AliceTranslationKey.callResponseHeadersEmpty: "Headers are empty",
        AliceTranslationKey.callResponseBodyImage: "Body: Image",
        AliceTranslationKey.callResponseBody: "Body:",
        AliceTranslationKey.callResponseTooLargeToShow: "Too large to show",
        AliceTranslationKey.callResponseBodyShow: "Show body",
        AliceTranslationKey.callResponseLargeBodyShowWarning:
            'Warning! It will take some time to render output.',
        AliceTranslationKey.callResponseBodyVideo: 'Body: Video',
        AliceTranslationKey.callResponseBodyVideoWebBrowser:
            'Open video in web browser',
        AliceTranslationKey.callResponseHeadersUnknown: "Unknown",
        AliceTranslationKey.callResponseBodyUnknown:
            'Unsupported body. Alice'
            ' can render video/image/text body. Response has Content-Type: '
            "[contentType] which can't be handled. If you're feeling lucky you "
            "can try button below to try render body as text, but it may fail.",
        AliceTranslationKey.callResponseBodyUnknownShow:
            "Show unsupported body",
        AliceTranslationKey.callsListInspector: "Inspector",
        AliceTranslationKey.callsListLogger: "Logger",
        AliceTranslationKey.callsListDeleteLogsDialogTitle: "Delete logs",
        AliceTranslationKey.callsListDeleteLogsDialogDescription:
            "Do you want to clear logs?",
        AliceTranslationKey.callsListYes: "Yes",
        AliceTranslationKey.callsListNo: "No",
        AliceTranslationKey.callsListDeleteCallsDialogTitle: "Delete calls",
        AliceTranslationKey.callsListDeleteCallsDialogDescription:
            "Do you want to delete HTTP calls?",
        AliceTranslationKey.callsListSearchHint: "Search URL, headers, body...",
        AliceTranslationKey.callsListSort: "Sort",
        AliceTranslationKey.callsListDelete: "Delete",
        AliceTranslationKey.callsListStats: "Stats",
        AliceTranslationKey.callsListSave: "Save",
        AliceTranslationKey.logsEmpty: "There are no logs to show",
        AliceTranslationKey.callsListSearch: "Search",
        AliceTranslationKey.callsListClearSearch: "Clear search",
        AliceTranslationKey.callsListEmpty: "No HTTP calls yet",
        AliceTranslationKey.callsListEmptyDescription:
            "Requests made by your app will appear here.",
        AliceTranslationKey.callsListNoResults: "No calls match \"[query]\"",
        AliceTranslationKey.callsListRawLogs: "Toggle raw logs",
        AliceTranslationKey.callsListScrollTop: "Scroll to top",
        AliceTranslationKey.callsListScrollBottom: "Scroll to bottom",
        AliceTranslationKey.urlIssueTitle: "Malformed URL",
        AliceTranslationKey.urlIssueSuggestion: "Did you mean:",
        AliceTranslationKey.urlIssueMore: "+[count] more issues",
        AliceTranslationKey.urlIssuePortWithDot:
            "Port is separated with '.' instead of ':'",
        AliceTranslationKey.urlIssueMissingSlashAfterPort:
            "Missing '/' between port and path",
        AliceTranslationKey.urlIssueMissingSlashAfterHost:
            "Missing '/' between IP address and path",
        AliceTranslationKey.urlIssueMissingSlashAfterVersion:
            "Missing '/' after API version",
        AliceTranslationKey.urlIssueInvalidIp: "IP address is invalid",
        AliceTranslationKey.urlIssueDoubleSlash: "Path contains '//'",
        AliceTranslationKey.urlIssueWhitespace: "URL contains whitespace",
        AliceTranslationKey.urlIssueMissingScheme:
            "URL has no http:// or https:// scheme",
        AliceTranslationKey.callOverviewTiming: "Timing",
        AliceTranslationKey.callOverviewConnection: "Connection",
        AliceTranslationKey.callOverviewCopyUrl: "Copy URL",
        AliceTranslationKey.callOverviewCopied: "URL copied to clipboard",
        AliceTranslationKey.callOverviewPending: "Pending…",
        AliceTranslationKey.callOverviewCopyAll: "Copy all request data",
        AliceTranslationKey.callOverviewCopiedAll:
            "Request data copied to clipboard",
        AliceTranslationKey.callOverviewCopy: "Copy",
        AliceTranslationKey.callOverviewCopiedValue: "Copied to clipboard",
        AliceTranslationKey.callOverviewShowMore: "Show more",
        AliceTranslationKey.callOverviewShowLess: "Show less",
        AliceTranslationKey.statusCategoryInformational: "Informational",
        AliceTranslationKey.statusCategorySuccess: "Success",
        AliceTranslationKey.statusCategoryRedirection: "Redirection",
        AliceTranslationKey.statusCategoryClientError: "Client error",
        AliceTranslationKey.statusCategoryServerError: "Server error",
        AliceTranslationKey.statusCategoryFailed: "No response",
        AliceTranslationKey.statusUnknownDescription:
            "There is no description for this status code.",
        AliceTranslationKey.statusTapHint: "What does this status mean?",
        AliceTranslationKey.logsError: "Failed to display error",
        AliceTranslationKey.logsItemError: "Error:",
        AliceTranslationKey.logsItemStackTrace: "Stack trace:",
        AliceTranslationKey.logsCopied: "Copied to clipboard.",
        AliceTranslationKey.sortDialogTitle: "Sort calls",
        AliceTranslationKey.sortDialogAscending: 'Ascending',
        AliceTranslationKey.sortDialogDescending: "Descending",
        AliceTranslationKey.sortDialogAccept: "Accept",
        AliceTranslationKey.sortDialogCancel: "Cancel",
        AliceTranslationKey.sortDialogTime: "Create time (default)",
        AliceTranslationKey.sortDialogResponseTime: "Response time",
        AliceTranslationKey.sortDialogResponseCode: "Response code",
        AliceTranslationKey.sortDialogResponseSize: "Response size",
        AliceTranslationKey.sortDialogEndpoint: "Endpoint",
        AliceTranslationKey.statsTitle: "Stats",
        AliceTranslationKey.statsSectionIssues: "Who is responsible",
        AliceTranslationKey.statsSectionTraffic: "Traffic",
        AliceTranslationKey.statsSectionTiming: "Response time",
        AliceTranslationKey.statsSectionMethods: "Methods",
        AliceTranslationKey.statsSectionSecurity: "Connection security",
        AliceTranslationKey.statsSuccessRate: "success rate",
        AliceTranslationKey.statsNoIssues: "No failed calls",
        AliceTranslationKey.sortDialogOrder: "Order",
        AliceTranslationKey.statsTotalRequests: "Total requests:",
        AliceTranslationKey.statsPendingRequests: "Pending requests:",
        AliceTranslationKey.statsSuccessRequests: "Success requests:",
        AliceTranslationKey.statsRedirectionRequests: "Redirection requests:",
        AliceTranslationKey.statsErrorRequests: "Error requests:",
        AliceTranslationKey.statsBytesSent: "Bytes sent:",
        AliceTranslationKey.statsBytesReceived: "Bytes received:",
        AliceTranslationKey.statsAverageRequestTime: "Average request time:",
        AliceTranslationKey.statsMaxRequestTime: "Max request time:",
        AliceTranslationKey.statsMinRequestTime: "Min request time:",
        AliceTranslationKey.statsGetRequests: "GET requests:",
        AliceTranslationKey.statsPostRequests: "POST requests:",
        AliceTranslationKey.statsDeleteRequests: "DELETE requests:",
        AliceTranslationKey.statsPutRequests: "PUT requests:",
        AliceTranslationKey.statsPatchRequests: "PATCH requests:",
        AliceTranslationKey.statsSecuredRequests: "Secured requests:",
        AliceTranslationKey.statsUnsecuredRequests: "Unsecured requests:",
        AliceTranslationKey.notificationLoading: "Loading:",
        AliceTranslationKey.notificationSuccess: "Success:",
        AliceTranslationKey.notificationRedirect: "Redirect:",
        AliceTranslationKey.notificationError: "Error:",
        AliceTranslationKey.notificationTotalRequests:
            "Alice (total [callCount] HTTP calls)",
        AliceTranslationKey.saveDialogPermissionErrorTitle: "Permission error",
        AliceTranslationKey.saveDialogPermissionErrorDescription:
            "Permission not granted. Couldn't save logs.",
        AliceTranslationKey.saveDialogEmptyErrorTitle: "Call history empty",
        AliceTranslationKey.saveDialogEmptyErrorDescription:
            "There are no calls to save.",
        AliceTranslationKey.saveDialogFileSaveErrorTitle: "Save error",
        AliceTranslationKey.saveDialogFileSaveErrorDescription:
            "Failed to save http calls to file.",
        AliceTranslationKey.saveSuccessTitle: "Logs saved",
        AliceTranslationKey.saveSuccessDescription:
            "Successfully saved logs in [path].",
        AliceTranslationKey.saveSuccessView: "View file",
        AliceTranslationKey.saveHeaderTitle: "Alice - HTTP Inspector",
        AliceTranslationKey.saveHeaderAppName: "App name:",
        AliceTranslationKey.saveHeaderPackage: "Package:",
        AliceTranslationKey.saveHeaderVersion: "Version:",
        AliceTranslationKey.saveHeaderBuildNumber: "Build number:",
        AliceTranslationKey.saveHeaderGenerated: "Generated:",
        AliceTranslationKey.saveLogId: "Id:",
        AliceTranslationKey.saveLogGeneralData: "General data",
        AliceTranslationKey.saveLogServer: "Server:",
        AliceTranslationKey.saveLogMethod: "Method:",
        AliceTranslationKey.saveLogEndpoint: "Endpoint:",
        AliceTranslationKey.saveLogClient: "Client:",
        AliceTranslationKey.saveLogDuration: "Duration:",
        AliceTranslationKey.saveLogSecured: "Secured connection:",
        AliceTranslationKey.saveLogCompleted: "Completed:",
        AliceTranslationKey.saveLogRequest: "Request",
        AliceTranslationKey.saveLogRequestTime: "Request time:",
        AliceTranslationKey.saveLogRequestContentType: "Request content type:",
        AliceTranslationKey.saveLogRequestCookies: "Request cookies:",
        AliceTranslationKey.saveLogRequestHeaders: "Request headers:",
        AliceTranslationKey.saveLogRequestQueryParams: "Request query params:",
        AliceTranslationKey.saveLogRequestSize: "Request size:",
        AliceTranslationKey.saveLogRequestBody: "Request body:",
        AliceTranslationKey.saveLogResponse: "Response",
        AliceTranslationKey.saveLogResponseTime: "Response time:",
        AliceTranslationKey.saveLogResponseStatus: "Response status:",
        AliceTranslationKey.saveLogResponseSize: "Response size:",
        AliceTranslationKey.saveLogResponseHeaders: "Response headers:",
        AliceTranslationKey.saveLogResponseBody: "Response body:",
        AliceTranslationKey.saveLogError: "Error",
        AliceTranslationKey.saveLogStackTrace: "Stack trace",
        AliceTranslationKey.saveLogCurl: "Curl",
        AliceTranslationKey.accept: "Accept",
        AliceTranslationKey.parserFailed: "Failed to parse: ",
        AliceTranslationKey.unknown: "Unknown",
        AliceTranslationKey.language: "Language",
        AliceTranslationKey.settings: "Settings",
        AliceTranslationKey.theme: "Theme",
        AliceTranslationKey.themeSystem: "System",
        AliceTranslationKey.themeLight: "Light",
        AliceTranslationKey.themeDark: "Dark",
        AliceTranslationKey.issueFrontend: "Frontend issue",
        AliceTranslationKey.issueBackend: "Backend issue",
        AliceTranslationKey.issueNetwork: "Network issue",
        AliceTranslationKey.issueReasonMalformedUrl:
            "The request URL is malformed, so the request can't reach the "
            "backend. Fix the URL in the app.",
        AliceTranslationKey.issueReasonClientError:
            "The backend rejected the request (HTTP [status]). Check the "
            "data, headers and parameters the app sends.",
        AliceTranslationKey.issueReasonNotFound:
            "The endpoint was not found (HTTP [status]). Check the URL and "
            "path used by the app.",
        AliceTranslationKey.issueReasonAuth:
            "The request is not authorized (HTTP [status]). Check the token "
            "the app sends and the permissions of the user.",
        AliceTranslationKey.issueReasonServerError:
            "The backend failed to handle the request (HTTP [status]). "
            "Report it to the backend team.",
        AliceTranslationKey.issueReasonGateway:
            "The backend or a gateway in front of it is unavailable (HTTP "
            "[status]). Report it to the backend team.",
        AliceTranslationKey.issueReasonNetwork:
            "No valid response was received. Check the connection, DNS, "
            "certificates and timeouts. [error]",
        AliceTranslationKey.issueReasonAppError:
            "The app failed while building the request or handling the "
            "response: [error]",
        AliceTranslationKey.logsFilterAll: "All",
        AliceTranslationKey.logsFilterRequests: "Requests",
        AliceTranslationKey.logsFilterResponses: "Responses",
        AliceTranslationKey.logsFilterErrors: "Errors",
        AliceTranslationKey.logsFilterWarnings: "Warnings",
        AliceTranslationKey.logsFilterEmpty: "No logs match this filter",
        AliceTranslationKey.logKindRequest: "Request",
        AliceTranslationKey.logKindResponse: "Response",
        AliceTranslationKey.logKindError: "Error",
        AliceTranslationKey.logKindWarning: "Warning",
        AliceTranslationKey.logKindInfo: "Info",
        AliceTranslationKey.watcher: "Response watcher",
        AliceTranslationKey.watcherSubtitle:
            "Use a field of the response as the status code",
        AliceTranslationKey.watcherDescription:
            "Some backends always answer with HTTP 200 and report the real "
            "result in a field of the response, for example \"type\": 2. "
            "Watch that field and tell Alice what each value means. Alice "
            "then shows the result next to the status code.",
        AliceTranslationKey.watcherFieldName: "Field name",
        AliceTranslationKey.watcherFieldHint: "For example type or data.status",
        AliceTranslationKey.watcherUseAsStatus: "Use as status code",
        AliceTranslationKey.watcherUseAsStatusHint:
            "Show the result next to the HTTP status and use it to detect "
            "failures.",
        AliceTranslationKey.watcherValues: "Values",
        AliceTranslationKey.watcherValue: "Value",
        AliceTranslationKey.watcherMeaning: "Meaning",
        AliceTranslationKey.watcherAddValue: "Add value",
        AliceTranslationKey.watcherAddField: "Add field",
        AliceTranslationKey.watcherDelete: "Delete",
        AliceTranslationKey.watcherReset: "Reset to default",
        AliceTranslationKey.watcherResetConfirm:
            "Replace all watched fields with the default ones?",
        AliceTranslationKey.watcherNoFields: "No watched fields yet",
        AliceTranslationKey.watcherNoValues: "No values yet",
        AliceTranslationKey.watcherOutcomeSuccess: "Success",
        AliceTranslationKey.watcherOutcomeFailed: "Failed",
        AliceTranslationKey.watcherOutcomeServerDown: "Server is down",
        AliceTranslationKey.issueReasonWatchFailed:
            "The response reports a failure although the HTTP status is fine: "
            "[error]",
        AliceTranslationKey.issueReasonWatchServerDown:
            "The response reports that the server is down although the HTTP "
            "status is fine: [error]",
        AliceTranslationKey.callErrorScreenType: "Type",
        AliceTranslationKey.callResponseBodyUnsupportedTitle:
            "Unsupported content",
        AliceTranslationKey.callResponseBodyUnsupportedDescription:
            "Alice can render JSON, XML, text, image and video bodies. This "
            "response has Content-Type [contentType], which can't be previewed.",
        AliceTranslationKey.callResponseBodyUnsupportedWarning:
            "You can try to show the body as raw text, but it may be "
            "unreadable.",
        AliceTranslationKey.callDetailsRevealSensitive: "Show hidden values",
        AliceTranslationKey.callDetailsHideSensitive: "Hide sensitive values",
        AliceTranslationKey.filtersFailed: "Failed",
        AliceTranslationKey.filtersPending: "Pending",
        AliceTranslationKey.filtersHost: "Host",
        AliceTranslationKey.filtersAllHosts: "All hosts",
        AliceTranslationKey.filtersClear: "Clear filters",
        AliceTranslationKey.callsListNoFilterResults:
            "No calls match the filters",
        AliceTranslationKey.replayAction: "Edit and resend",
        AliceTranslationKey.replayMethod: "Method",
        AliceTranslationKey.replayUrl: "URL",
        AliceTranslationKey.replayHeaders: "Headers",
        AliceTranslationKey.replayHeadersHint:
            "One header per line, as Name: value",
        AliceTranslationKey.replayBody: "Body",
        AliceTranslationKey.replaySend: "Send",
        AliceTranslationKey.replayReset: "Reset",
        AliceTranslationKey.replaySent:
            "Request sent. The new call is at the top of the list.",
        AliceTranslationKey.replayFailed: "Request couldn't be sent: [error]",
        AliceTranslationKey.replayFormDataWarning:
            "This call sent form data. Alice keeps only the names and sizes of form data, so the body is empty.",
        AliceTranslationKey.replayInvalidUrl:
            "Enter a full URL, for example https://api.example.com/users",
        AliceTranslationKey.replayInvalidHeader:
            "Line [line] isn't a header. Use Name: value.",
        AliceTranslationKey.jsonViewTree: "Tree",
        AliceTranslationKey.jsonViewRaw: "Raw",
        AliceTranslationKey.jsonSearchHint: "Search keys and values",
        AliceTranslationKey.jsonExpandAll: "Expand all",
        AliceTranslationKey.jsonCollapseAll: "Collapse all",
        AliceTranslationKey.jsonCopyValue: "Copy value",
        AliceTranslationKey.jsonCopyPath: "Copy path",
        AliceTranslationKey.jsonMatches: "[count] matches",
        AliceTranslationKey.jsonNoMatches: "No matches",
        AliceTranslationKey.callsListExportHar: "Export HAR",
        AliceTranslationKey.callOverviewGraphQL: "GraphQL:",
        AliceTranslationKey.graphQLErrors: "GraphQL errors",
        AliceTranslationKey.callsListTimeline: "Timeline",
        AliceTranslationKey.timelineEmpty: "No calls to show yet",
        AliceTranslationKey.timelineSummary:
            "[count] calls over [duration], up to [concurrency] at once",
        AliceTranslationKey.statsSectionSlowest: "Slowest endpoints",
        AliceTranslationKey.statsEndpointCalls: "[count] calls",
        AliceTranslationKey.statsEndpointFailures: "[count] failed",
      },
    );
  }

  /// Builds [AliceTranslationData] for arabic language.
  static AliceTranslationData _buildArTranslations() {
    return AliceTranslationData(
      languageCode: "ar",
      values: {
        AliceTranslationKey.alice: "Alice",
        AliceTranslationKey.callDetails: "تفاصيل طلب HTTP",
        AliceTranslationKey.emailSubject: "تقرير Alice",
        AliceTranslationKey.callDetailsOverview: "نظرة عامة",
        AliceTranslationKey.callDetailsRequest: "الطلب",
        AliceTranslationKey.callDetailsResponse: "الاستجابة",
        AliceTranslationKey.callDetailsError: "الخطأ",
        AliceTranslationKey.callDetailsEmpty: "فشل تحميل البيانات",
        AliceTranslationKey.callErrorScreenErrorEmpty: "لا يوجد خطأ",
        AliceTranslationKey.callErrorScreenError: "الخطأ:",
        AliceTranslationKey.callErrorScreenStacktrace: "تتبع المكدس:",
        AliceTranslationKey.callErrorScreenEmpty: "لا يوجد شيء لعرضه هنا",
        AliceTranslationKey.callOverviewMethod: "الطريقة:",
        AliceTranslationKey.callOverviewServer: "الخادم:",
        AliceTranslationKey.callOverviewEndpoint: "نقطة النهاية:",
        AliceTranslationKey.callOverviewStarted: "البدء:",
        AliceTranslationKey.callOverviewFinished: "الانتهاء:",
        AliceTranslationKey.callOverviewDuration: "المدة:",
        AliceTranslationKey.callOverviewBytesSent: "البيانات المرسلة:",
        AliceTranslationKey.callOverviewBytesReceived: "البيانات المستلمة:",
        AliceTranslationKey.callOverviewClient: "العميل:",
        AliceTranslationKey.callOverviewSecure: "آمن:",
        AliceTranslationKey.callRequestStarted: "البدء:",
        AliceTranslationKey.callRequestBytesSent: "البيانات المرسلة:",
        AliceTranslationKey.callRequestContentType: "نوع المحتوى:",
        AliceTranslationKey.callRequestBody: "المحتوى:",
        AliceTranslationKey.callRequestBodyEmpty: "المحتوى فارغ",
        AliceTranslationKey.callRequestFormDataFields: "حقول النموذج:",
        AliceTranslationKey.callRequestFormDataFiles: "ملفات النموذج:",
        AliceTranslationKey.callRequestHeaders: "الترويسات:",
        AliceTranslationKey.callRequestHeadersEmpty: "الترويسات فارغة",
        AliceTranslationKey.callRequestQueryParameters: "معاملات الاستعلام",
        AliceTranslationKey.callRequestQueryParametersEmpty:
            "معاملات الاستعلام فارغة",
        AliceTranslationKey.callResponseWaitingForResponse:
            "بانتظار الاستجابة...",
        AliceTranslationKey.callResponseError: "خطأ",
        AliceTranslationKey.callResponseReceived: "الاستلام:",
        AliceTranslationKey.callResponseBytesReceived: "البيانات المستلمة:",
        AliceTranslationKey.callResponseStatus: "الحالة:",
        AliceTranslationKey.callResponseHeaders: "الترويسات:",
        AliceTranslationKey.callResponseHeadersEmpty: "الترويسات فارغة",
        AliceTranslationKey.callResponseBodyImage: "المحتوى: صورة",
        AliceTranslationKey.callResponseBody: "المحتوى:",
        AliceTranslationKey.callResponseTooLargeToShow: "أكبر من أن يُعرض",
        AliceTranslationKey.callResponseBodyShow: "عرض المحتوى",
        AliceTranslationKey.callResponseLargeBodyShowWarning:
            "تحذير! سيستغرق عرض الناتج بعض الوقت.",
        AliceTranslationKey.callResponseBodyVideo: "المحتوى: فيديو",
        AliceTranslationKey.callResponseBodyVideoWebBrowser:
            "فتح الفيديو في المتصفح",
        AliceTranslationKey.callResponseHeadersUnknown: "غير معروف",
        AliceTranslationKey.callResponseBodyUnknown:
            "محتوى غير مدعوم. يستطيع Alice عرض محتوى الفيديو والصور والنصوص. نوع محتوى الاستجابة [contentType] ولا يمكن معالجته. يمكنك تجربة الزر أدناه لعرض المحتوى كنص، لكن قد يفشل ذلك.",
        AliceTranslationKey.callResponseBodyUnknownShow:
            "عرض المحتوى غير المدعوم",
        AliceTranslationKey.callsListInspector: "المراقب",
        AliceTranslationKey.callsListLogger: "السجلات",
        AliceTranslationKey.callsListDeleteLogsDialogTitle: "حذف السجلات",
        AliceTranslationKey.callsListDeleteLogsDialogDescription:
            "هل تريد مسح السجلات؟",
        AliceTranslationKey.callsListYes: "نعم",
        AliceTranslationKey.callsListNo: "لا",
        AliceTranslationKey.callsListDeleteCallsDialogTitle: "حذف الطلبات",
        AliceTranslationKey.callsListDeleteCallsDialogDescription:
            "هل تريد حذف طلبات HTTP؟",
        AliceTranslationKey.callsListSearchHint:
            "ابحث في الرابط والترويسات والمحتوى...",
        AliceTranslationKey.callsListSort: "ترتيب",
        AliceTranslationKey.callsListDelete: "حذف",
        AliceTranslationKey.callsListStats: "الإحصائيات",
        AliceTranslationKey.callsListSave: "حفظ",
        AliceTranslationKey.logsEmpty: "لا توجد سجلات لعرضها",
        AliceTranslationKey.callsListSearch: "بحث",
        AliceTranslationKey.callsListClearSearch: "مسح البحث",
        AliceTranslationKey.callsListEmpty: "لا توجد طلبات HTTP بعد",
        AliceTranslationKey.callsListEmptyDescription:
            "ستظهر هنا الطلبات التي يرسلها تطبيقك.",
        AliceTranslationKey.callsListNoResults:
            "لا توجد طلبات تطابق \"[query]\"",
        AliceTranslationKey.callsListRawLogs: "تبديل السجلات الخام",
        AliceTranslationKey.callsListScrollTop: "التمرير للأعلى",
        AliceTranslationKey.callsListScrollBottom: "التمرير للأسفل",
        AliceTranslationKey.urlIssueTitle: "رابط غير صالح",
        AliceTranslationKey.urlIssueSuggestion: "هل تقصد:",
        AliceTranslationKey.urlIssueMore: "+[count] مشاكل أخرى",
        AliceTranslationKey.urlIssuePortWithDot:
            "تم فصل المنفذ بـ '.' بدلاً من ':'",
        AliceTranslationKey.urlIssueMissingSlashAfterPort:
            "ينقص '/' بين المنفذ والمسار",
        AliceTranslationKey.urlIssueMissingSlashAfterHost:
            "ينقص '/' بين عنوان IP والمسار",
        AliceTranslationKey.urlIssueMissingSlashAfterVersion:
            "ينقص '/' بعد إصدار الـ API",
        AliceTranslationKey.urlIssueInvalidIp: "عنوان IP غير صالح",
        AliceTranslationKey.urlIssueDoubleSlash: "المسار يحتوي على '//'",
        AliceTranslationKey.urlIssueWhitespace: "الرابط يحتوي على مسافات",
        AliceTranslationKey.urlIssueMissingScheme:
            "الرابط لا يبدأ بـ http:// أو https://",
        AliceTranslationKey.callOverviewTiming: "التوقيت",
        AliceTranslationKey.callOverviewConnection: "الاتصال",
        AliceTranslationKey.callOverviewCopyUrl: "نسخ الرابط",
        AliceTranslationKey.callOverviewCopied: "تم نسخ الرابط إلى الحافظة",
        AliceTranslationKey.callOverviewPending: "قيد الانتظار…",
        AliceTranslationKey.callOverviewCopyAll: "نسخ كل بيانات الطلب",
        AliceTranslationKey.callOverviewCopiedAll:
            "تم نسخ بيانات الطلب إلى الحافظة",
        AliceTranslationKey.callOverviewCopy: "نسخ",
        AliceTranslationKey.callOverviewCopiedValue: "تم النسخ إلى الحافظة",
        AliceTranslationKey.callOverviewShowMore: "عرض المزيد",
        AliceTranslationKey.callOverviewShowLess: "عرض أقل",
        AliceTranslationKey.statusCategoryInformational: "معلوماتية",
        AliceTranslationKey.statusCategorySuccess: "نجاح",
        AliceTranslationKey.statusCategoryRedirection: "إعادة توجيه",
        AliceTranslationKey.statusCategoryClientError: "خطأ من العميل",
        AliceTranslationKey.statusCategoryServerError: "خطأ من الخادم",
        AliceTranslationKey.statusCategoryFailed: "لا توجد استجابة",
        AliceTranslationKey.statusUnknownDescription:
            "لا يوجد وصف لرمز الحالة هذا.",
        AliceTranslationKey.statusTapHint: "ماذا يعني رمز الحالة هذا؟",
        AliceTranslationKey.logsError: "فشل عرض الخطأ",
        AliceTranslationKey.logsItemError: "الخطأ:",
        AliceTranslationKey.logsItemStackTrace: "تتبع المكدس:",
        AliceTranslationKey.logsCopied: "تم النسخ إلى الحافظة.",
        AliceTranslationKey.sortDialogTitle: "اختر طريقة الترتيب",
        AliceTranslationKey.sortDialogAscending: "تصاعدي",
        AliceTranslationKey.sortDialogDescending: "تنازلي",
        AliceTranslationKey.sortDialogAccept: "موافق",
        AliceTranslationKey.sortDialogCancel: "إلغاء",
        AliceTranslationKey.sortDialogTime: "وقت الإنشاء (افتراضي)",
        AliceTranslationKey.sortDialogResponseTime: "وقت الاستجابة",
        AliceTranslationKey.sortDialogResponseCode: "رمز الاستجابة",
        AliceTranslationKey.sortDialogResponseSize: "حجم الاستجابة",
        AliceTranslationKey.sortDialogEndpoint: "نقطة النهاية",
        AliceTranslationKey.statsTitle: "الإحصائيات",
        AliceTranslationKey.statsSectionIssues: "المسؤول عن الأخطاء",
        AliceTranslationKey.statsSectionTraffic: "حركة البيانات",
        AliceTranslationKey.statsSectionTiming: "زمن الاستجابة",
        AliceTranslationKey.statsSectionMethods: "أنواع الطلبات",
        AliceTranslationKey.statsSectionSecurity: "أمان الاتصال",
        AliceTranslationKey.statsSuccessRate: "نسبة النجاح",
        AliceTranslationKey.statsNoIssues: "لا توجد طلبات فاشلة",
        AliceTranslationKey.sortDialogOrder: "الترتيب",
        AliceTranslationKey.statsTotalRequests: "إجمالي الطلبات:",
        AliceTranslationKey.statsPendingRequests: "الطلبات المعلقة:",
        AliceTranslationKey.statsSuccessRequests: "الطلبات الناجحة:",
        AliceTranslationKey.statsRedirectionRequests: "طلبات إعادة التوجيه:",
        AliceTranslationKey.statsErrorRequests: "الطلبات الفاشلة:",
        AliceTranslationKey.statsBytesSent: "البيانات المرسلة:",
        AliceTranslationKey.statsBytesReceived: "البيانات المستلمة:",
        AliceTranslationKey.statsAverageRequestTime: "متوسط وقت الطلب:",
        AliceTranslationKey.statsMaxRequestTime: "أطول وقت طلب:",
        AliceTranslationKey.statsMinRequestTime: "أقصر وقت طلب:",
        AliceTranslationKey.statsGetRequests: "طلبات GET:",
        AliceTranslationKey.statsPostRequests: "طلبات POST:",
        AliceTranslationKey.statsDeleteRequests: "طلبات DELETE:",
        AliceTranslationKey.statsPutRequests: "طلبات PUT:",
        AliceTranslationKey.statsPatchRequests: "طلبات PATCH:",
        AliceTranslationKey.statsSecuredRequests: "الطلبات الآمنة:",
        AliceTranslationKey.statsUnsecuredRequests: "الطلبات غير الآمنة:",
        AliceTranslationKey.notificationLoading: "قيد التحميل:",
        AliceTranslationKey.notificationSuccess: "نجاح:",
        AliceTranslationKey.notificationRedirect: "إعادة توجيه:",
        AliceTranslationKey.notificationError: "خطأ:",
        AliceTranslationKey.notificationTotalRequests:
            "Alice (إجمالي [callCount] طلب HTTP)",
        AliceTranslationKey.saveDialogPermissionErrorTitle: "خطأ في الصلاحيات",
        AliceTranslationKey.saveDialogPermissionErrorDescription:
            "لم يتم منح الصلاحية. تعذر حفظ السجلات.",
        AliceTranslationKey.saveDialogEmptyErrorTitle: "سجل الطلبات فارغ",
        AliceTranslationKey.saveDialogEmptyErrorDescription:
            "لا توجد طلبات لحفظها.",
        AliceTranslationKey.saveDialogFileSaveErrorTitle: "خطأ في الحفظ",
        AliceTranslationKey.saveDialogFileSaveErrorDescription:
            "فشل حفظ طلبات HTTP في ملف.",
        AliceTranslationKey.saveSuccessTitle: "تم حفظ السجلات",
        AliceTranslationKey.saveSuccessDescription:
            "تم حفظ السجلات بنجاح في [path].",
        AliceTranslationKey.saveSuccessView: "عرض الملف",
        AliceTranslationKey.saveHeaderTitle: "Alice - مراقب HTTP",
        AliceTranslationKey.saveHeaderAppName: "اسم التطبيق:",
        AliceTranslationKey.saveHeaderPackage: "الحزمة:",
        AliceTranslationKey.saveHeaderVersion: "الإصدار:",
        AliceTranslationKey.saveHeaderBuildNumber: "رقم البناء:",
        AliceTranslationKey.saveHeaderGenerated: "تاريخ الإنشاء:",
        AliceTranslationKey.saveLogId: "المعرف:",
        AliceTranslationKey.saveLogGeneralData: "بيانات عامة",
        AliceTranslationKey.saveLogServer: "الخادم:",
        AliceTranslationKey.saveLogMethod: "الطريقة:",
        AliceTranslationKey.saveLogEndpoint: "نقطة النهاية:",
        AliceTranslationKey.saveLogClient: "العميل:",
        AliceTranslationKey.saveLogDuration: "المدة:",
        AliceTranslationKey.saveLogSecured: "اتصال آمن:",
        AliceTranslationKey.saveLogCompleted: "مكتمل:",
        AliceTranslationKey.saveLogRequest: "الطلب",
        AliceTranslationKey.saveLogRequestTime: "وقت الطلب:",
        AliceTranslationKey.saveLogRequestContentType: "نوع محتوى الطلب:",
        AliceTranslationKey.saveLogRequestCookies:
            "ملفات تعريف الارتباط للطلب:",
        AliceTranslationKey.saveLogRequestHeaders: "ترويسات الطلب:",
        AliceTranslationKey.saveLogRequestQueryParams: "معاملات استعلام الطلب:",
        AliceTranslationKey.saveLogRequestSize: "حجم الطلب:",
        AliceTranslationKey.saveLogRequestBody: "محتوى الطلب:",
        AliceTranslationKey.saveLogResponse: "الاستجابة",
        AliceTranslationKey.saveLogResponseTime: "وقت الاستجابة:",
        AliceTranslationKey.saveLogResponseStatus: "حالة الاستجابة:",
        AliceTranslationKey.saveLogResponseSize: "حجم الاستجابة:",
        AliceTranslationKey.saveLogResponseHeaders: "ترويسات الاستجابة:",
        AliceTranslationKey.saveLogResponseBody: "محتوى الاستجابة:",
        AliceTranslationKey.saveLogError: "الخطأ",
        AliceTranslationKey.saveLogStackTrace: "تتبع المكدس",
        AliceTranslationKey.saveLogCurl: "Curl",
        AliceTranslationKey.accept: "موافق",
        AliceTranslationKey.parserFailed: "فشل التحليل: ",
        AliceTranslationKey.unknown: "غير معروف",
        AliceTranslationKey.language: "اللغة",
        AliceTranslationKey.settings: "الإعدادات",
        AliceTranslationKey.theme: "المظهر",
        AliceTranslationKey.themeSystem: "النظام",
        AliceTranslationKey.themeLight: "فاتح",
        AliceTranslationKey.themeDark: "داكن",
        AliceTranslationKey.issueFrontend: "مشكلة في التطبيق",
        AliceTranslationKey.issueBackend: "مشكلة في الخادم",
        AliceTranslationKey.issueNetwork: "مشكلة في الشبكة",
        AliceTranslationKey.issueReasonMalformedUrl:
            "عنوان الطلب غير صحيح، لذلك لا يمكن أن يصل إلى الخادم. "
            "صحّح العنوان في التطبيق.",
        AliceTranslationKey.issueReasonClientError:
            "رفض الخادم الطلب (HTTP [status]). تحقق من البيانات والترويسات "
            "والمعاملات التي يرسلها التطبيق.",
        AliceTranslationKey.issueReasonNotFound:
            "لم يتم العثور على نقطة النهاية (HTTP [status]). تحقق من العنوان "
            "والمسار المستخدم في التطبيق.",
        AliceTranslationKey.issueReasonAuth:
            "الطلب غير مصرّح به (HTTP [status]). تحقق من الرمز الذي يرسله "
            "التطبيق وصلاحيات المستخدم.",
        AliceTranslationKey.issueReasonServerError:
            "فشل الخادم في معالجة الطلب (HTTP [status]). أبلغ فريق الخادم.",
        AliceTranslationKey.issueReasonGateway:
            "الخادم أو البوابة التي أمامه غير متاحة (HTTP [status]). أبلغ "
            "فريق الخادم.",
        AliceTranslationKey.issueReasonNetwork:
            "لم يتم استلام استجابة صالحة. تحقق من الاتصال وخدمة DNS "
            "والشهادات ومهلات الانتظار. [error]",
        AliceTranslationKey.issueReasonAppError:
            "فشل التطبيق أثناء بناء الطلب أو معالجة الاستجابة: [error]",
        AliceTranslationKey.logsFilterAll: "الكل",
        AliceTranslationKey.logsFilterRequests: "الطلبات",
        AliceTranslationKey.logsFilterResponses: "الاستجابات",
        AliceTranslationKey.logsFilterErrors: "الأخطاء",
        AliceTranslationKey.logsFilterWarnings: "التحذيرات",
        AliceTranslationKey.logsFilterEmpty: "لا توجد سجلات مطابقة",
        AliceTranslationKey.logKindRequest: "طلب",
        AliceTranslationKey.logKindResponse: "استجابة",
        AliceTranslationKey.logKindError: "خطأ",
        AliceTranslationKey.logKindWarning: "تحذير",
        AliceTranslationKey.logKindInfo: "معلومة",
        AliceTranslationKey.watcher: "مراقب الاستجابة",
        AliceTranslationKey.watcherSubtitle:
            "استخدم حقلاً من الاستجابة كرمز للحالة",
        AliceTranslationKey.watcherDescription:
            "بعض الخوادم ترد دائماً بـ HTTP 200 وتضع النتيجة الحقيقية في حقل "
            "داخل الاستجابة، مثل \"type\": 2. راقب هذا الحقل وحدد معنى كل "
            "قيمة، وسيعرض Alice النتيجة بجانب رمز الحالة.",
        AliceTranslationKey.watcherFieldName: "اسم الحقل",
        AliceTranslationKey.watcherFieldHint: "مثل type أو data.status",
        AliceTranslationKey.watcherUseAsStatus: "استخدام كرمز للحالة",
        AliceTranslationKey.watcherUseAsStatusHint:
            "عرض النتيجة بجانب حالة HTTP واستخدامها لاكتشاف الأخطاء.",
        AliceTranslationKey.watcherValues: "القيم",
        AliceTranslationKey.watcherValue: "القيمة",
        AliceTranslationKey.watcherMeaning: "المعنى",
        AliceTranslationKey.watcherAddValue: "إضافة قيمة",
        AliceTranslationKey.watcherAddField: "إضافة حقل",
        AliceTranslationKey.watcherDelete: "حذف",
        AliceTranslationKey.watcherReset: "استعادة الافتراضي",
        AliceTranslationKey.watcherResetConfirm:
            "استبدال كل حقول المراقبة بالحقول الافتراضية؟",
        AliceTranslationKey.watcherNoFields: "لا توجد حقول مراقبة بعد",
        AliceTranslationKey.watcherNoValues: "لا توجد قيم بعد",
        AliceTranslationKey.watcherOutcomeSuccess: "نجاح",
        AliceTranslationKey.watcherOutcomeFailed: "فشل",
        AliceTranslationKey.watcherOutcomeServerDown: "الخادم متوقف",
        AliceTranslationKey.issueReasonWatchFailed:
            "تشير الاستجابة إلى فشل رغم أن حالة HTTP سليمة: [error]",
        AliceTranslationKey.issueReasonWatchServerDown:
            "تشير الاستجابة إلى أن الخادم متوقف رغم أن حالة HTTP سليمة: "
            "[error]",
        AliceTranslationKey.callErrorScreenType: "النوع",
        AliceTranslationKey.callResponseBodyUnsupportedTitle: "محتوى غير مدعوم",
        AliceTranslationKey.callResponseBodyUnsupportedDescription:
            "يمكن لـ Alice عرض JSON وXML والنصوص والصور والفيديو. نوع "
            "المحتوى [contentType] لهذه الاستجابة لا يمكن معاينته.",
        AliceTranslationKey.callResponseBodyUnsupportedWarning:
            "يمكنك محاولة عرض المحتوى كنص خام، لكنه قد يكون غير مقروء.",
        AliceTranslationKey.callDetailsRevealSensitive: "إظهار القيم المخفية",
        AliceTranslationKey.callDetailsHideSensitive: "إخفاء القيم الحساسة",
        AliceTranslationKey.filtersFailed: "فشل",
        AliceTranslationKey.filtersPending: "قيد الانتظار",
        AliceTranslationKey.filtersHost: "الخادم",
        AliceTranslationKey.filtersAllHosts: "كل الخوادم",
        AliceTranslationKey.filtersClear: "مسح الفلاتر",
        AliceTranslationKey.callsListNoFilterResults:
            "لا توجد طلبات تطابق الفلاتر",
        AliceTranslationKey.replayAction: "تعديل وإعادة الإرسال",
        AliceTranslationKey.replayMethod: "الطريقة",
        AliceTranslationKey.replayUrl: "الرابط",
        AliceTranslationKey.replayHeaders: "الترويسات",
        AliceTranslationKey.replayHeadersHint:
            "ترويسة واحدة في كل سطر، بالشكل الاسم: القيمة",
        AliceTranslationKey.replayBody: "المحتوى",
        AliceTranslationKey.replaySend: "إرسال",
        AliceTranslationKey.replayReset: "إعادة التعيين",
        AliceTranslationKey.replaySent:
            "تم إرسال الطلب. الطلب الجديد في أعلى القائمة.",
        AliceTranslationKey.replayFailed: "تعذر إرسال الطلب: [error]",
        AliceTranslationKey.replayFormDataWarning:
            "أرسل هذا الطلب بيانات نموذج. يحتفظ Alice بأسماء البيانات وأحجامها فقط، لذلك المحتوى فارغ.",
        AliceTranslationKey.replayInvalidUrl:
            "أدخل رابطًا كاملًا، مثل https://api.example.com/users",
        AliceTranslationKey.replayInvalidHeader:
            "السطر [line] ليس ترويسة. استخدم الاسم: القيمة.",
        AliceTranslationKey.jsonViewTree: "شجرة",
        AliceTranslationKey.jsonViewRaw: "نص خام",
        AliceTranslationKey.jsonSearchHint: "ابحث في المفاتيح والقيم",
        AliceTranslationKey.jsonExpandAll: "توسيع الكل",
        AliceTranslationKey.jsonCollapseAll: "طي الكل",
        AliceTranslationKey.jsonCopyValue: "نسخ القيمة",
        AliceTranslationKey.jsonCopyPath: "نسخ المسار",
        AliceTranslationKey.jsonMatches: "عدد النتائج: [count]",
        AliceTranslationKey.jsonNoMatches: "لا توجد نتائج",
        AliceTranslationKey.callsListExportHar: "تصدير HAR",
        AliceTranslationKey.callOverviewGraphQL: "GraphQL:",
        AliceTranslationKey.graphQLErrors: "أخطاء GraphQL",
        AliceTranslationKey.callsListTimeline: "المخطط الزمني",
        AliceTranslationKey.timelineEmpty: "لا توجد طلبات لعرضها بعد",
        AliceTranslationKey.timelineSummary:
            "[count] طلب خلال [duration]، وحتى [concurrency] في الوقت نفسه",
        AliceTranslationKey.statsSectionSlowest: "أبطأ نقاط النهاية",
        AliceTranslationKey.statsEndpointCalls: "عدد الطلبات: [count]",
        AliceTranslationKey.statsEndpointFailures: "فشل: [count]",
      },
    );
  }

  /// Returns localized value for specific [languageCode] and [key]. English
  /// is used when language or key is not translated. If value can't be
  /// selected then [key] will be returned.
  static String get({
    required String languageCode,
    required AliceTranslationKey key,
  }) {
    try {
      final data = _translations.firstWhere(
        (element) => element.languageCode == languageCode,
        orElse: () => _translations.first,
      );
      // Fall back to English (first language) for keys missing in [data].
      return data.values[key] ??
          _translations.first.values[key] ??
          key.toString();
    } catch (error) {
      return key.toString();
    }
  }
}
