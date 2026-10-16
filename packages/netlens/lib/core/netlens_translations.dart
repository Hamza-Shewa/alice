import 'package:netlens/model/netlens_translation.dart';

/// Class used to manage translations in NetLens.
class NetLensTranslations {
  /// Contains list of translation data for all languages.
  static final List<NetLensTranslationData> _translations = _initialise();

  /// Initialises translation data for all languages.
  static List<NetLensTranslationData> _initialise() {
    List<NetLensTranslationData> translations = [];
    translations.add(_buildEnTranslations());
    translations.add(_buildArTranslations());
    return translations;
  }

  /// Builds [NetLensTranslationData] for english language.
  static NetLensTranslationData _buildEnTranslations() {
    return NetLensTranslationData(
      languageCode: "en",
      values: {
        NetLensTranslationKey.netLens: "NetLens",
        NetLensTranslationKey.callDetails: "HTTP Call Details",
        NetLensTranslationKey.emailSubject: "NetLens report",
        NetLensTranslationKey.callDetailsRequest: "Request",
        NetLensTranslationKey.callDetailsResponse: "Response",
        NetLensTranslationKey.callDetailsOverview: "Overview",
        NetLensTranslationKey.callDetailsError: "Error",
        NetLensTranslationKey.callDetailsEmpty: "Loading data failed",
        NetLensTranslationKey.callErrorScreenErrorEmpty: "Error is empty",
        NetLensTranslationKey.callErrorScreenError: "Error:",
        NetLensTranslationKey.callErrorScreenStacktrace: "Stack trace:",
        NetLensTranslationKey.callErrorScreenEmpty: "Nothing to display here",
        NetLensTranslationKey.callOverviewMethod: "Method:",
        NetLensTranslationKey.callOverviewServer: "Server:",
        NetLensTranslationKey.callOverviewEndpoint: "Endpoint:",
        NetLensTranslationKey.callOverviewStarted: "Started:",
        NetLensTranslationKey.callOverviewFinished: "Finished:",
        NetLensTranslationKey.callOverviewDuration: "Duration:",
        NetLensTranslationKey.callOverviewBytesSent: "Bytes sent:",
        NetLensTranslationKey.callOverviewBytesReceived: "Bytes received:",
        NetLensTranslationKey.callOverviewClient: "Client:",
        NetLensTranslationKey.callOverviewSecure: "Secure:",
        NetLensTranslationKey.callRequestStarted: "Started:",
        NetLensTranslationKey.callRequestBytesSent: "Bytes sent:",
        NetLensTranslationKey.callRequestContentType: "Content type:",
        NetLensTranslationKey.callRequestBody: "Body:",
        NetLensTranslationKey.callRequestBodyEmpty: "Body is empty",
        NetLensTranslationKey.callRequestFormDataFields: "Form data fields:",
        NetLensTranslationKey.callRequestFormDataFiles: "Form files:",
        NetLensTranslationKey.callRequestHeaders: "Headers:",
        NetLensTranslationKey.callRequestHeadersEmpty: "Headers are empty",
        NetLensTranslationKey.callRequestQueryParameters: "Query parameters",
        NetLensTranslationKey.callRequestQueryParametersEmpty:
            "Query parameters are empty",
        NetLensTranslationKey.callResponseWaitingForResponse:
            "Awaiting response...",
        NetLensTranslationKey.callResponseError: "Error",
        NetLensTranslationKey.callResponseReceived: "Received:",
        NetLensTranslationKey.callResponseBytesReceived: "Bytes received:",
        NetLensTranslationKey.callResponseStatus: "Status:",
        NetLensTranslationKey.callResponseHeaders: "Headers:",
        NetLensTranslationKey.callResponseHeadersEmpty: "Headers are empty",
        NetLensTranslationKey.callResponseBodyImage: "Body: Image",
        NetLensTranslationKey.callResponseBody: "Body:",
        NetLensTranslationKey.callResponseTooLargeToShow: "Too large to show",
        NetLensTranslationKey.callResponseBodyShow: "Show body",
        NetLensTranslationKey.callResponseLargeBodyShowWarning:
            'Warning! It will take some time to render output.',
        NetLensTranslationKey.callResponseBodyVideo: 'Body: Video',
        NetLensTranslationKey.callResponseBodyVideoWebBrowser:
            'Open video in web browser',
        NetLensTranslationKey.callResponseHeadersUnknown: "Unknown",
        NetLensTranslationKey.callResponseBodyUnknown:
            'Unsupported body. NetLens'
            ' can render video/image/text body. Response has Content-Type: '
            "[contentType] which can't be handled. If you're feeling lucky you "
            "can try button below to try render body as text, but it may fail.",
        NetLensTranslationKey.callResponseBodyUnknownShow:
            "Show unsupported body",
        NetLensTranslationKey.callsListInspector: "Inspector",
        NetLensTranslationKey.callsListLogger: "Logger",
        NetLensTranslationKey.callsListDeleteLogsDialogTitle: "Delete logs",
        NetLensTranslationKey.callsListDeleteLogsDialogDescription:
            "Do you want to clear logs?",
        NetLensTranslationKey.callsListYes: "Yes",
        NetLensTranslationKey.callsListNo: "No",
        NetLensTranslationKey.callsListDeleteCallsDialogTitle: "Delete calls",
        NetLensTranslationKey.callsListDeleteCallsDialogDescription:
            "Do you want to delete HTTP calls?",
        NetLensTranslationKey.callsListSearchHint:
            "Search URL, headers, body...",
        NetLensTranslationKey.callsListSort: "Sort",
        NetLensTranslationKey.callsListDelete: "Delete",
        NetLensTranslationKey.callsListStats: "Stats",
        NetLensTranslationKey.callsListSave: "Save",
        NetLensTranslationKey.logsEmpty: "There are no logs to show",
        NetLensTranslationKey.callsListSearch: "Search",
        NetLensTranslationKey.callsListClearSearch: "Clear search",
        NetLensTranslationKey.callsListEmpty: "No HTTP calls yet",
        NetLensTranslationKey.callsListEmptyDescription:
            "Requests made by your app will appear here.",
        NetLensTranslationKey.callsListNoResults: "No calls match \"[query]\"",
        NetLensTranslationKey.callsListRawLogs: "Toggle raw logs",
        NetLensTranslationKey.callsListScrollTop: "Scroll to top",
        NetLensTranslationKey.callsListScrollBottom: "Scroll to bottom",
        NetLensTranslationKey.urlIssueTitle: "Malformed URL",
        NetLensTranslationKey.urlIssueSuggestion: "Did you mean:",
        NetLensTranslationKey.urlIssueMore: "+[count] more issues",
        NetLensTranslationKey.urlIssuePortWithDot:
            "Port is separated with '.' instead of ':'",
        NetLensTranslationKey.urlIssueMissingSlashAfterPort:
            "Missing '/' between port and path",
        NetLensTranslationKey.urlIssueMissingSlashAfterHost:
            "Missing '/' between IP address and path",
        NetLensTranslationKey.urlIssueMissingSlashAfterVersion:
            "Missing '/' after API version",
        NetLensTranslationKey.urlIssueInvalidIp: "IP address is invalid",
        NetLensTranslationKey.urlIssueDoubleSlash: "Path contains '//'",
        NetLensTranslationKey.urlIssueWhitespace: "URL contains whitespace",
        NetLensTranslationKey.urlIssueMissingScheme:
            "URL has no http:// or https:// scheme",
        NetLensTranslationKey.callOverviewTiming: "Timing",
        NetLensTranslationKey.callOverviewConnection: "Connection",
        NetLensTranslationKey.callOverviewCopyUrl: "Copy URL",
        NetLensTranslationKey.callOverviewCopied: "URL copied to clipboard",
        NetLensTranslationKey.callOverviewPending: "Pending…",
        NetLensTranslationKey.callOverviewCopyAll: "Copy all request data",
        NetLensTranslationKey.callOverviewCopiedAll:
            "Request data copied to clipboard",
        NetLensTranslationKey.callOverviewCopy: "Copy",
        NetLensTranslationKey.callOverviewCopiedValue: "Copied to clipboard",
        NetLensTranslationKey.callOverviewShowMore: "Show more",
        NetLensTranslationKey.callOverviewShowLess: "Show less",
        NetLensTranslationKey.statusCategoryInformational: "Informational",
        NetLensTranslationKey.statusCategorySuccess: "Success",
        NetLensTranslationKey.statusCategoryRedirection: "Redirection",
        NetLensTranslationKey.statusCategoryClientError: "Client error",
        NetLensTranslationKey.statusCategoryServerError: "Server error",
        NetLensTranslationKey.statusCategoryFailed: "No response",
        NetLensTranslationKey.statusUnknownDescription:
            "There is no description for this status code.",
        NetLensTranslationKey.statusTapHint: "What does this status mean?",
        NetLensTranslationKey.logsError: "Failed to display error",
        NetLensTranslationKey.logsItemError: "Error:",
        NetLensTranslationKey.logsItemStackTrace: "Stack trace:",
        NetLensTranslationKey.logsCopied: "Copied to clipboard.",
        NetLensTranslationKey.sortDialogTitle: "Sort calls",
        NetLensTranslationKey.sortDialogAscending: 'Ascending',
        NetLensTranslationKey.sortDialogDescending: "Descending",
        NetLensTranslationKey.sortDialogAccept: "Accept",
        NetLensTranslationKey.sortDialogCancel: "Cancel",
        NetLensTranslationKey.sortDialogTime: "Create time (default)",
        NetLensTranslationKey.sortDialogResponseTime: "Response time",
        NetLensTranslationKey.sortDialogResponseCode: "Response code",
        NetLensTranslationKey.sortDialogResponseSize: "Response size",
        NetLensTranslationKey.sortDialogEndpoint: "Endpoint",
        NetLensTranslationKey.statsTitle: "Stats",
        NetLensTranslationKey.statsSectionIssues: "Who is responsible",
        NetLensTranslationKey.statsSectionTraffic: "Traffic",
        NetLensTranslationKey.statsSectionTiming: "Response time",
        NetLensTranslationKey.statsSectionMethods: "Methods",
        NetLensTranslationKey.statsSectionSecurity: "Connection security",
        NetLensTranslationKey.statsSuccessRate: "success rate",
        NetLensTranslationKey.statsNoIssues: "No failed calls",
        NetLensTranslationKey.sortDialogOrder: "Order",
        NetLensTranslationKey.statsTotalRequests: "Total requests:",
        NetLensTranslationKey.statsPendingRequests: "Pending requests:",
        NetLensTranslationKey.statsSuccessRequests: "Success requests:",
        NetLensTranslationKey.statsRedirectionRequests: "Redirection requests:",
        NetLensTranslationKey.statsErrorRequests: "Error requests:",
        NetLensTranslationKey.statsBytesSent: "Bytes sent:",
        NetLensTranslationKey.statsBytesReceived: "Bytes received:",
        NetLensTranslationKey.statsAverageRequestTime: "Average request time:",
        NetLensTranslationKey.statsMaxRequestTime: "Max request time:",
        NetLensTranslationKey.statsMinRequestTime: "Min request time:",
        NetLensTranslationKey.statsGetRequests: "GET requests:",
        NetLensTranslationKey.statsPostRequests: "POST requests:",
        NetLensTranslationKey.statsDeleteRequests: "DELETE requests:",
        NetLensTranslationKey.statsPutRequests: "PUT requests:",
        NetLensTranslationKey.statsPatchRequests: "PATCH requests:",
        NetLensTranslationKey.statsSecuredRequests: "Secured requests:",
        NetLensTranslationKey.statsUnsecuredRequests: "Unsecured requests:",
        NetLensTranslationKey.notificationLoading: "Loading:",
        NetLensTranslationKey.notificationSuccess: "Success:",
        NetLensTranslationKey.notificationRedirect: "Redirect:",
        NetLensTranslationKey.notificationError: "Error:",
        NetLensTranslationKey.notificationTotalRequests:
            "NetLens (total [callCount] HTTP calls)",
        NetLensTranslationKey.saveDialogPermissionErrorTitle:
            "Permission error",
        NetLensTranslationKey.saveDialogPermissionErrorDescription:
            "Permission not granted. Couldn't save logs.",
        NetLensTranslationKey.saveDialogEmptyErrorTitle: "Call history empty",
        NetLensTranslationKey.saveDialogEmptyErrorDescription:
            "There are no calls to save.",
        NetLensTranslationKey.saveDialogFileSaveErrorTitle: "Save error",
        NetLensTranslationKey.saveDialogFileSaveErrorDescription:
            "Failed to save http calls to file.",
        NetLensTranslationKey.saveSuccessTitle: "Logs saved",
        NetLensTranslationKey.saveSuccessDescription:
            "Successfully saved logs in [path].",
        NetLensTranslationKey.saveSuccessView: "View file",
        NetLensTranslationKey.saveHeaderTitle: "NetLens - HTTP Inspector",
        NetLensTranslationKey.saveHeaderAppName: "App name:",
        NetLensTranslationKey.saveHeaderPackage: "Package:",
        NetLensTranslationKey.saveHeaderVersion: "Version:",
        NetLensTranslationKey.saveHeaderBuildNumber: "Build number:",
        NetLensTranslationKey.saveHeaderGenerated: "Generated:",
        NetLensTranslationKey.saveLogId: "Id:",
        NetLensTranslationKey.saveLogGeneralData: "General data",
        NetLensTranslationKey.saveLogServer: "Server:",
        NetLensTranslationKey.saveLogMethod: "Method:",
        NetLensTranslationKey.saveLogEndpoint: "Endpoint:",
        NetLensTranslationKey.saveLogClient: "Client:",
        NetLensTranslationKey.saveLogDuration: "Duration:",
        NetLensTranslationKey.saveLogSecured: "Secured connection:",
        NetLensTranslationKey.saveLogCompleted: "Completed:",
        NetLensTranslationKey.saveLogRequest: "Request",
        NetLensTranslationKey.saveLogRequestTime: "Request time:",
        NetLensTranslationKey.saveLogRequestContentType:
            "Request content type:",
        NetLensTranslationKey.saveLogRequestCookies: "Request cookies:",
        NetLensTranslationKey.saveLogRequestHeaders: "Request headers:",
        NetLensTranslationKey.saveLogRequestQueryParams:
            "Request query params:",
        NetLensTranslationKey.saveLogRequestSize: "Request size:",
        NetLensTranslationKey.saveLogRequestBody: "Request body:",
        NetLensTranslationKey.saveLogResponse: "Response",
        NetLensTranslationKey.saveLogResponseTime: "Response time:",
        NetLensTranslationKey.saveLogResponseStatus: "Response status:",
        NetLensTranslationKey.saveLogResponseSize: "Response size:",
        NetLensTranslationKey.saveLogResponseHeaders: "Response headers:",
        NetLensTranslationKey.saveLogResponseBody: "Response body:",
        NetLensTranslationKey.saveLogError: "Error",
        NetLensTranslationKey.saveLogStackTrace: "Stack trace",
        NetLensTranslationKey.saveLogCurl: "Curl",
        NetLensTranslationKey.accept: "Accept",
        NetLensTranslationKey.parserFailed: "Failed to parse: ",
        NetLensTranslationKey.unknown: "Unknown",
        NetLensTranslationKey.language: "Language",
        NetLensTranslationKey.settings: "Settings",
        NetLensTranslationKey.theme: "Theme",
        NetLensTranslationKey.themeSystem: "System",
        NetLensTranslationKey.themeLight: "Light",
        NetLensTranslationKey.themeDark: "Dark",
        NetLensTranslationKey.issueFrontend: "Frontend issue",
        NetLensTranslationKey.issueBackend: "Backend issue",
        NetLensTranslationKey.issueNetwork: "Network issue",
        NetLensTranslationKey.issueReasonMalformedUrl:
            "The request URL is malformed, so the request can't reach the "
            "backend. Fix the URL in the app.",
        NetLensTranslationKey.issueReasonClientError:
            "The backend rejected the request (HTTP [status]). Check the "
            "data, headers and parameters the app sends.",
        NetLensTranslationKey.issueReasonNotFound:
            "The endpoint was not found (HTTP [status]). Check the URL and "
            "path used by the app.",
        NetLensTranslationKey.issueReasonAuth:
            "The request is not authorized (HTTP [status]). Check the token "
            "the app sends and the permissions of the user.",
        NetLensTranslationKey.issueReasonServerError:
            "The backend failed to handle the request (HTTP [status]). "
            "Report it to the backend team.",
        NetLensTranslationKey.issueReasonGateway:
            "The backend or a gateway in front of it is unavailable (HTTP "
            "[status]). Report it to the backend team.",
        NetLensTranslationKey.issueReasonNetwork:
            "No valid response was received. Check the connection, DNS, "
            "certificates and timeouts. [error]",
        NetLensTranslationKey.issueReasonAppError:
            "The app failed while building the request or handling the "
            "response: [error]",
        NetLensTranslationKey.logsFilterAll: "All",
        NetLensTranslationKey.logsFilterRequests: "Requests",
        NetLensTranslationKey.logsFilterResponses: "Responses",
        NetLensTranslationKey.logsFilterErrors: "Errors",
        NetLensTranslationKey.logsFilterWarnings: "Warnings",
        NetLensTranslationKey.logsFilterEmpty: "No logs match this filter",
        NetLensTranslationKey.logKindRequest: "Request",
        NetLensTranslationKey.logKindResponse: "Response",
        NetLensTranslationKey.logKindError: "Error",
        NetLensTranslationKey.logKindWarning: "Warning",
        NetLensTranslationKey.logKindInfo: "Info",
        NetLensTranslationKey.watcher: "Response watcher",
        NetLensTranslationKey.watcherSubtitle:
            "Use a field of the response as the status code",
        NetLensTranslationKey.watcherDescription:
            "Some backends always answer with HTTP 200 and report the real "
            "result in a field of the response, for example \"type\": 2. "
            "Watch that field and tell NetLens what each value means. NetLens "
            "then shows the result next to the status code.",
        NetLensTranslationKey.watcherFieldName: "Field name",
        NetLensTranslationKey.watcherFieldHint:
            "For example type or data.status",
        NetLensTranslationKey.watcherUseAsStatus: "Use as status code",
        NetLensTranslationKey.watcherUseAsStatusHint:
            "Show the result next to the HTTP status and use it to detect "
            "failures.",
        NetLensTranslationKey.watcherValues: "Values",
        NetLensTranslationKey.watcherValue: "Value",
        NetLensTranslationKey.watcherMeaning: "Meaning",
        NetLensTranslationKey.watcherAddValue: "Add value",
        NetLensTranslationKey.watcherAddField: "Add field",
        NetLensTranslationKey.watcherDelete: "Delete",
        NetLensTranslationKey.watcherReset: "Reset to default",
        NetLensTranslationKey.watcherResetConfirm:
            "Replace all watched fields with the default ones?",
        NetLensTranslationKey.watcherNoFields: "No watched fields yet",
        NetLensTranslationKey.watcherNoValues: "No values yet",
        NetLensTranslationKey.watcherOutcomeSuccess: "Success",
        NetLensTranslationKey.watcherOutcomeFailed: "Failed",
        NetLensTranslationKey.watcherOutcomeServerDown: "Server is down",
        NetLensTranslationKey.issueReasonWatchFailed:
            "The response reports a failure although the HTTP status is fine: "
            "[error]",
        NetLensTranslationKey.issueReasonWatchServerDown:
            "The response reports that the server is down although the HTTP "
            "status is fine: [error]",
        NetLensTranslationKey.callErrorScreenType: "Type",
        NetLensTranslationKey.callResponseBodyUnsupportedTitle:
            "Unsupported content",
        NetLensTranslationKey.callResponseBodyUnsupportedDescription:
            "NetLens can render JSON, XML, text, image and video bodies. This "
            "response has Content-Type [contentType], which can't be previewed.",
        NetLensTranslationKey.callResponseBodyUnsupportedWarning:
            "You can try to show the body as raw text, but it may be "
            "unreadable.",
        NetLensTranslationKey.callDetailsRevealSensitive: "Show hidden values",
        NetLensTranslationKey.callDetailsHideSensitive: "Hide sensitive values",
        NetLensTranslationKey.filtersFailed: "Failed",
        NetLensTranslationKey.filtersPending: "Pending",
        NetLensTranslationKey.filtersHost: "Host",
        NetLensTranslationKey.filtersAllHosts: "All hosts",
        NetLensTranslationKey.filtersClear: "Clear filters",
        NetLensTranslationKey.callsListNoFilterResults:
            "No calls match the filters",
        NetLensTranslationKey.replayAction: "Edit and resend",
        NetLensTranslationKey.replayMethod: "Method",
        NetLensTranslationKey.replayUrl: "URL",
        NetLensTranslationKey.replayHeaders: "Headers",
        NetLensTranslationKey.replayHeadersHint:
            "One header per line, as Name: value",
        NetLensTranslationKey.replayBody: "Body",
        NetLensTranslationKey.replaySend: "Send",
        NetLensTranslationKey.replayReset: "Reset",
        NetLensTranslationKey.replaySent:
            "Request sent. The new call is at the top of the list.",
        NetLensTranslationKey.replayFailed: "Request couldn't be sent: [error]",
        NetLensTranslationKey.replayFormDataWarning:
            "This call sent form data. NetLens keeps only the names and sizes of form data, so the body is empty.",
        NetLensTranslationKey.replayInvalidUrl:
            "Enter a full URL, for example https://api.example.com/users",
        NetLensTranslationKey.replayInvalidHeader:
            "Line [line] isn't a header. Use Name: value.",
        NetLensTranslationKey.jsonViewTree: "Tree",
        NetLensTranslationKey.jsonViewRaw: "Raw",
        NetLensTranslationKey.jsonSearchHint: "Search keys and values",
        NetLensTranslationKey.jsonExpandAll: "Expand all",
        NetLensTranslationKey.jsonCollapseAll: "Collapse all",
        NetLensTranslationKey.jsonCopyValue: "Copy value",
        NetLensTranslationKey.jsonCopyPath: "Copy path",
        NetLensTranslationKey.jsonMatches: "[count] matches",
        NetLensTranslationKey.jsonNoMatches: "No matches",
        NetLensTranslationKey.callsListExportHar: "Export HAR",
        NetLensTranslationKey.callOverviewGraphQL: "GraphQL:",
        NetLensTranslationKey.graphQLErrors: "GraphQL errors",
        NetLensTranslationKey.callsListTimeline: "Timeline",
        NetLensTranslationKey.timelineEmpty: "No calls to show yet",
        NetLensTranslationKey.timelineSummary:
            "[count] calls over [duration], up to [concurrency] at once",
        NetLensTranslationKey.statsSectionSlowest: "Slowest endpoints",
        NetLensTranslationKey.statsEndpointCalls: "[count] calls",
        NetLensTranslationKey.statsEndpointFailures: "[count] failed",
      },
    );
  }

  /// Builds [NetLensTranslationData] for arabic language.
  static NetLensTranslationData _buildArTranslations() {
    return NetLensTranslationData(
      languageCode: "ar",
      values: {
        NetLensTranslationKey.netLens: "NetLens",
        NetLensTranslationKey.callDetails: "تفاصيل طلب HTTP",
        NetLensTranslationKey.emailSubject: "تقرير NetLens",
        NetLensTranslationKey.callDetailsOverview: "نظرة عامة",
        NetLensTranslationKey.callDetailsRequest: "الطلب",
        NetLensTranslationKey.callDetailsResponse: "الاستجابة",
        NetLensTranslationKey.callDetailsError: "الخطأ",
        NetLensTranslationKey.callDetailsEmpty: "فشل تحميل البيانات",
        NetLensTranslationKey.callErrorScreenErrorEmpty: "لا يوجد خطأ",
        NetLensTranslationKey.callErrorScreenError: "الخطأ:",
        NetLensTranslationKey.callErrorScreenStacktrace: "تتبع المكدس:",
        NetLensTranslationKey.callErrorScreenEmpty: "لا يوجد شيء لعرضه هنا",
        NetLensTranslationKey.callOverviewMethod: "الطريقة:",
        NetLensTranslationKey.callOverviewServer: "الخادم:",
        NetLensTranslationKey.callOverviewEndpoint: "نقطة النهاية:",
        NetLensTranslationKey.callOverviewStarted: "البدء:",
        NetLensTranslationKey.callOverviewFinished: "الانتهاء:",
        NetLensTranslationKey.callOverviewDuration: "المدة:",
        NetLensTranslationKey.callOverviewBytesSent: "البيانات المرسلة:",
        NetLensTranslationKey.callOverviewBytesReceived: "البيانات المستلمة:",
        NetLensTranslationKey.callOverviewClient: "العميل:",
        NetLensTranslationKey.callOverviewSecure: "آمن:",
        NetLensTranslationKey.callRequestStarted: "البدء:",
        NetLensTranslationKey.callRequestBytesSent: "البيانات المرسلة:",
        NetLensTranslationKey.callRequestContentType: "نوع المحتوى:",
        NetLensTranslationKey.callRequestBody: "المحتوى:",
        NetLensTranslationKey.callRequestBodyEmpty: "المحتوى فارغ",
        NetLensTranslationKey.callRequestFormDataFields: "حقول النموذج:",
        NetLensTranslationKey.callRequestFormDataFiles: "ملفات النموذج:",
        NetLensTranslationKey.callRequestHeaders: "الترويسات:",
        NetLensTranslationKey.callRequestHeadersEmpty: "الترويسات فارغة",
        NetLensTranslationKey.callRequestQueryParameters: "معاملات الاستعلام",
        NetLensTranslationKey.callRequestQueryParametersEmpty:
            "معاملات الاستعلام فارغة",
        NetLensTranslationKey.callResponseWaitingForResponse:
            "بانتظار الاستجابة...",
        NetLensTranslationKey.callResponseError: "خطأ",
        NetLensTranslationKey.callResponseReceived: "الاستلام:",
        NetLensTranslationKey.callResponseBytesReceived: "البيانات المستلمة:",
        NetLensTranslationKey.callResponseStatus: "الحالة:",
        NetLensTranslationKey.callResponseHeaders: "الترويسات:",
        NetLensTranslationKey.callResponseHeadersEmpty: "الترويسات فارغة",
        NetLensTranslationKey.callResponseBodyImage: "المحتوى: صورة",
        NetLensTranslationKey.callResponseBody: "المحتوى:",
        NetLensTranslationKey.callResponseTooLargeToShow: "أكبر من أن يُعرض",
        NetLensTranslationKey.callResponseBodyShow: "عرض المحتوى",
        NetLensTranslationKey.callResponseLargeBodyShowWarning:
            "تحذير! سيستغرق عرض الناتج بعض الوقت.",
        NetLensTranslationKey.callResponseBodyVideo: "المحتوى: فيديو",
        NetLensTranslationKey.callResponseBodyVideoWebBrowser:
            "فتح الفيديو في المتصفح",
        NetLensTranslationKey.callResponseHeadersUnknown: "غير معروف",
        NetLensTranslationKey.callResponseBodyUnknown:
            "محتوى غير مدعوم. يستطيع NetLens عرض محتوى الفيديو والصور والنصوص. نوع محتوى الاستجابة [contentType] ولا يمكن معالجته. يمكنك تجربة الزر أدناه لعرض المحتوى كنص، لكن قد يفشل ذلك.",
        NetLensTranslationKey.callResponseBodyUnknownShow:
            "عرض المحتوى غير المدعوم",
        NetLensTranslationKey.callsListInspector: "المراقب",
        NetLensTranslationKey.callsListLogger: "السجلات",
        NetLensTranslationKey.callsListDeleteLogsDialogTitle: "حذف السجلات",
        NetLensTranslationKey.callsListDeleteLogsDialogDescription:
            "هل تريد مسح السجلات؟",
        NetLensTranslationKey.callsListYes: "نعم",
        NetLensTranslationKey.callsListNo: "لا",
        NetLensTranslationKey.callsListDeleteCallsDialogTitle: "حذف الطلبات",
        NetLensTranslationKey.callsListDeleteCallsDialogDescription:
            "هل تريد حذف طلبات HTTP؟",
        NetLensTranslationKey.callsListSearchHint:
            "ابحث في الرابط والترويسات والمحتوى...",
        NetLensTranslationKey.callsListSort: "ترتيب",
        NetLensTranslationKey.callsListDelete: "حذف",
        NetLensTranslationKey.callsListStats: "الإحصائيات",
        NetLensTranslationKey.callsListSave: "حفظ",
        NetLensTranslationKey.logsEmpty: "لا توجد سجلات لعرضها",
        NetLensTranslationKey.callsListSearch: "بحث",
        NetLensTranslationKey.callsListClearSearch: "مسح البحث",
        NetLensTranslationKey.callsListEmpty: "لا توجد طلبات HTTP بعد",
        NetLensTranslationKey.callsListEmptyDescription:
            "ستظهر هنا الطلبات التي يرسلها تطبيقك.",
        NetLensTranslationKey.callsListNoResults:
            "لا توجد طلبات تطابق \"[query]\"",
        NetLensTranslationKey.callsListRawLogs: "تبديل السجلات الخام",
        NetLensTranslationKey.callsListScrollTop: "التمرير للأعلى",
        NetLensTranslationKey.callsListScrollBottom: "التمرير للأسفل",
        NetLensTranslationKey.urlIssueTitle: "رابط غير صالح",
        NetLensTranslationKey.urlIssueSuggestion: "هل تقصد:",
        NetLensTranslationKey.urlIssueMore: "+[count] مشاكل أخرى",
        NetLensTranslationKey.urlIssuePortWithDot:
            "تم فصل المنفذ بـ '.' بدلاً من ':'",
        NetLensTranslationKey.urlIssueMissingSlashAfterPort:
            "ينقص '/' بين المنفذ والمسار",
        NetLensTranslationKey.urlIssueMissingSlashAfterHost:
            "ينقص '/' بين عنوان IP والمسار",
        NetLensTranslationKey.urlIssueMissingSlashAfterVersion:
            "ينقص '/' بعد إصدار الـ API",
        NetLensTranslationKey.urlIssueInvalidIp: "عنوان IP غير صالح",
        NetLensTranslationKey.urlIssueDoubleSlash: "المسار يحتوي على '//'",
        NetLensTranslationKey.urlIssueWhitespace: "الرابط يحتوي على مسافات",
        NetLensTranslationKey.urlIssueMissingScheme:
            "الرابط لا يبدأ بـ http:// أو https://",
        NetLensTranslationKey.callOverviewTiming: "التوقيت",
        NetLensTranslationKey.callOverviewConnection: "الاتصال",
        NetLensTranslationKey.callOverviewCopyUrl: "نسخ الرابط",
        NetLensTranslationKey.callOverviewCopied: "تم نسخ الرابط إلى الحافظة",
        NetLensTranslationKey.callOverviewPending: "قيد الانتظار…",
        NetLensTranslationKey.callOverviewCopyAll: "نسخ كل بيانات الطلب",
        NetLensTranslationKey.callOverviewCopiedAll:
            "تم نسخ بيانات الطلب إلى الحافظة",
        NetLensTranslationKey.callOverviewCopy: "نسخ",
        NetLensTranslationKey.callOverviewCopiedValue: "تم النسخ إلى الحافظة",
        NetLensTranslationKey.callOverviewShowMore: "عرض المزيد",
        NetLensTranslationKey.callOverviewShowLess: "عرض أقل",
        NetLensTranslationKey.statusCategoryInformational: "معلوماتية",
        NetLensTranslationKey.statusCategorySuccess: "نجاح",
        NetLensTranslationKey.statusCategoryRedirection: "إعادة توجيه",
        NetLensTranslationKey.statusCategoryClientError: "خطأ من العميل",
        NetLensTranslationKey.statusCategoryServerError: "خطأ من الخادم",
        NetLensTranslationKey.statusCategoryFailed: "لا توجد استجابة",
        NetLensTranslationKey.statusUnknownDescription:
            "لا يوجد وصف لرمز الحالة هذا.",
        NetLensTranslationKey.statusTapHint: "ماذا يعني رمز الحالة هذا؟",
        NetLensTranslationKey.logsError: "فشل عرض الخطأ",
        NetLensTranslationKey.logsItemError: "الخطأ:",
        NetLensTranslationKey.logsItemStackTrace: "تتبع المكدس:",
        NetLensTranslationKey.logsCopied: "تم النسخ إلى الحافظة.",
        NetLensTranslationKey.sortDialogTitle: "اختر طريقة الترتيب",
        NetLensTranslationKey.sortDialogAscending: "تصاعدي",
        NetLensTranslationKey.sortDialogDescending: "تنازلي",
        NetLensTranslationKey.sortDialogAccept: "موافق",
        NetLensTranslationKey.sortDialogCancel: "إلغاء",
        NetLensTranslationKey.sortDialogTime: "وقت الإنشاء (افتراضي)",
        NetLensTranslationKey.sortDialogResponseTime: "وقت الاستجابة",
        NetLensTranslationKey.sortDialogResponseCode: "رمز الاستجابة",
        NetLensTranslationKey.sortDialogResponseSize: "حجم الاستجابة",
        NetLensTranslationKey.sortDialogEndpoint: "نقطة النهاية",
        NetLensTranslationKey.statsTitle: "الإحصائيات",
        NetLensTranslationKey.statsSectionIssues: "المسؤول عن الأخطاء",
        NetLensTranslationKey.statsSectionTraffic: "حركة البيانات",
        NetLensTranslationKey.statsSectionTiming: "زمن الاستجابة",
        NetLensTranslationKey.statsSectionMethods: "أنواع الطلبات",
        NetLensTranslationKey.statsSectionSecurity: "أمان الاتصال",
        NetLensTranslationKey.statsSuccessRate: "نسبة النجاح",
        NetLensTranslationKey.statsNoIssues: "لا توجد طلبات فاشلة",
        NetLensTranslationKey.sortDialogOrder: "الترتيب",
        NetLensTranslationKey.statsTotalRequests: "إجمالي الطلبات:",
        NetLensTranslationKey.statsPendingRequests: "الطلبات المعلقة:",
        NetLensTranslationKey.statsSuccessRequests: "الطلبات الناجحة:",
        NetLensTranslationKey.statsRedirectionRequests: "طلبات إعادة التوجيه:",
        NetLensTranslationKey.statsErrorRequests: "الطلبات الفاشلة:",
        NetLensTranslationKey.statsBytesSent: "البيانات المرسلة:",
        NetLensTranslationKey.statsBytesReceived: "البيانات المستلمة:",
        NetLensTranslationKey.statsAverageRequestTime: "متوسط وقت الطلب:",
        NetLensTranslationKey.statsMaxRequestTime: "أطول وقت طلب:",
        NetLensTranslationKey.statsMinRequestTime: "أقصر وقت طلب:",
        NetLensTranslationKey.statsGetRequests: "طلبات GET:",
        NetLensTranslationKey.statsPostRequests: "طلبات POST:",
        NetLensTranslationKey.statsDeleteRequests: "طلبات DELETE:",
        NetLensTranslationKey.statsPutRequests: "طلبات PUT:",
        NetLensTranslationKey.statsPatchRequests: "طلبات PATCH:",
        NetLensTranslationKey.statsSecuredRequests: "الطلبات الآمنة:",
        NetLensTranslationKey.statsUnsecuredRequests: "الطلبات غير الآمنة:",
        NetLensTranslationKey.notificationLoading: "قيد التحميل:",
        NetLensTranslationKey.notificationSuccess: "نجاح:",
        NetLensTranslationKey.notificationRedirect: "إعادة توجيه:",
        NetLensTranslationKey.notificationError: "خطأ:",
        NetLensTranslationKey.notificationTotalRequests:
            "NetLens (إجمالي [callCount] طلب HTTP)",
        NetLensTranslationKey.saveDialogPermissionErrorTitle:
            "خطأ في الصلاحيات",
        NetLensTranslationKey.saveDialogPermissionErrorDescription:
            "لم يتم منح الصلاحية. تعذر حفظ السجلات.",
        NetLensTranslationKey.saveDialogEmptyErrorTitle: "سجل الطلبات فارغ",
        NetLensTranslationKey.saveDialogEmptyErrorDescription:
            "لا توجد طلبات لحفظها.",
        NetLensTranslationKey.saveDialogFileSaveErrorTitle: "خطأ في الحفظ",
        NetLensTranslationKey.saveDialogFileSaveErrorDescription:
            "فشل حفظ طلبات HTTP في ملف.",
        NetLensTranslationKey.saveSuccessTitle: "تم حفظ السجلات",
        NetLensTranslationKey.saveSuccessDescription:
            "تم حفظ السجلات بنجاح في [path].",
        NetLensTranslationKey.saveSuccessView: "عرض الملف",
        NetLensTranslationKey.saveHeaderTitle: "NetLens - مراقب HTTP",
        NetLensTranslationKey.saveHeaderAppName: "اسم التطبيق:",
        NetLensTranslationKey.saveHeaderPackage: "الحزمة:",
        NetLensTranslationKey.saveHeaderVersion: "الإصدار:",
        NetLensTranslationKey.saveHeaderBuildNumber: "رقم البناء:",
        NetLensTranslationKey.saveHeaderGenerated: "تاريخ الإنشاء:",
        NetLensTranslationKey.saveLogId: "المعرف:",
        NetLensTranslationKey.saveLogGeneralData: "بيانات عامة",
        NetLensTranslationKey.saveLogServer: "الخادم:",
        NetLensTranslationKey.saveLogMethod: "الطريقة:",
        NetLensTranslationKey.saveLogEndpoint: "نقطة النهاية:",
        NetLensTranslationKey.saveLogClient: "العميل:",
        NetLensTranslationKey.saveLogDuration: "المدة:",
        NetLensTranslationKey.saveLogSecured: "اتصال آمن:",
        NetLensTranslationKey.saveLogCompleted: "مكتمل:",
        NetLensTranslationKey.saveLogRequest: "الطلب",
        NetLensTranslationKey.saveLogRequestTime: "وقت الطلب:",
        NetLensTranslationKey.saveLogRequestContentType: "نوع محتوى الطلب:",
        NetLensTranslationKey.saveLogRequestCookies:
            "ملفات تعريف الارتباط للطلب:",
        NetLensTranslationKey.saveLogRequestHeaders: "ترويسات الطلب:",
        NetLensTranslationKey.saveLogRequestQueryParams:
            "معاملات استعلام الطلب:",
        NetLensTranslationKey.saveLogRequestSize: "حجم الطلب:",
        NetLensTranslationKey.saveLogRequestBody: "محتوى الطلب:",
        NetLensTranslationKey.saveLogResponse: "الاستجابة",
        NetLensTranslationKey.saveLogResponseTime: "وقت الاستجابة:",
        NetLensTranslationKey.saveLogResponseStatus: "حالة الاستجابة:",
        NetLensTranslationKey.saveLogResponseSize: "حجم الاستجابة:",
        NetLensTranslationKey.saveLogResponseHeaders: "ترويسات الاستجابة:",
        NetLensTranslationKey.saveLogResponseBody: "محتوى الاستجابة:",
        NetLensTranslationKey.saveLogError: "الخطأ",
        NetLensTranslationKey.saveLogStackTrace: "تتبع المكدس",
        NetLensTranslationKey.saveLogCurl: "Curl",
        NetLensTranslationKey.accept: "موافق",
        NetLensTranslationKey.parserFailed: "فشل التحليل: ",
        NetLensTranslationKey.unknown: "غير معروف",
        NetLensTranslationKey.language: "اللغة",
        NetLensTranslationKey.settings: "الإعدادات",
        NetLensTranslationKey.theme: "المظهر",
        NetLensTranslationKey.themeSystem: "النظام",
        NetLensTranslationKey.themeLight: "فاتح",
        NetLensTranslationKey.themeDark: "داكن",
        NetLensTranslationKey.issueFrontend: "مشكلة في التطبيق",
        NetLensTranslationKey.issueBackend: "مشكلة في الخادم",
        NetLensTranslationKey.issueNetwork: "مشكلة في الشبكة",
        NetLensTranslationKey.issueReasonMalformedUrl:
            "عنوان الطلب غير صحيح، لذلك لا يمكن أن يصل إلى الخادم. "
            "صحّح العنوان في التطبيق.",
        NetLensTranslationKey.issueReasonClientError:
            "رفض الخادم الطلب (HTTP [status]). تحقق من البيانات والترويسات "
            "والمعاملات التي يرسلها التطبيق.",
        NetLensTranslationKey.issueReasonNotFound:
            "لم يتم العثور على نقطة النهاية (HTTP [status]). تحقق من العنوان "
            "والمسار المستخدم في التطبيق.",
        NetLensTranslationKey.issueReasonAuth:
            "الطلب غير مصرّح به (HTTP [status]). تحقق من الرمز الذي يرسله "
            "التطبيق وصلاحيات المستخدم.",
        NetLensTranslationKey.issueReasonServerError:
            "فشل الخادم في معالجة الطلب (HTTP [status]). أبلغ فريق الخادم.",
        NetLensTranslationKey.issueReasonGateway:
            "الخادم أو البوابة التي أمامه غير متاحة (HTTP [status]). أبلغ "
            "فريق الخادم.",
        NetLensTranslationKey.issueReasonNetwork:
            "لم يتم استلام استجابة صالحة. تحقق من الاتصال وخدمة DNS "
            "والشهادات ومهلات الانتظار. [error]",
        NetLensTranslationKey.issueReasonAppError:
            "فشل التطبيق أثناء بناء الطلب أو معالجة الاستجابة: [error]",
        NetLensTranslationKey.logsFilterAll: "الكل",
        NetLensTranslationKey.logsFilterRequests: "الطلبات",
        NetLensTranslationKey.logsFilterResponses: "الاستجابات",
        NetLensTranslationKey.logsFilterErrors: "الأخطاء",
        NetLensTranslationKey.logsFilterWarnings: "التحذيرات",
        NetLensTranslationKey.logsFilterEmpty: "لا توجد سجلات مطابقة",
        NetLensTranslationKey.logKindRequest: "طلب",
        NetLensTranslationKey.logKindResponse: "استجابة",
        NetLensTranslationKey.logKindError: "خطأ",
        NetLensTranslationKey.logKindWarning: "تحذير",
        NetLensTranslationKey.logKindInfo: "معلومة",
        NetLensTranslationKey.watcher: "مراقب الاستجابة",
        NetLensTranslationKey.watcherSubtitle:
            "استخدم حقلاً من الاستجابة كرمز للحالة",
        NetLensTranslationKey.watcherDescription:
            "بعض الخوادم ترد دائماً بـ HTTP 200 وتضع النتيجة الحقيقية في حقل "
            "داخل الاستجابة، مثل \"type\": 2. راقب هذا الحقل وحدد معنى كل "
            "قيمة، وسيعرض NetLens النتيجة بجانب رمز الحالة.",
        NetLensTranslationKey.watcherFieldName: "اسم الحقل",
        NetLensTranslationKey.watcherFieldHint: "مثل type أو data.status",
        NetLensTranslationKey.watcherUseAsStatus: "استخدام كرمز للحالة",
        NetLensTranslationKey.watcherUseAsStatusHint:
            "عرض النتيجة بجانب حالة HTTP واستخدامها لاكتشاف الأخطاء.",
        NetLensTranslationKey.watcherValues: "القيم",
        NetLensTranslationKey.watcherValue: "القيمة",
        NetLensTranslationKey.watcherMeaning: "المعنى",
        NetLensTranslationKey.watcherAddValue: "إضافة قيمة",
        NetLensTranslationKey.watcherAddField: "إضافة حقل",
        NetLensTranslationKey.watcherDelete: "حذف",
        NetLensTranslationKey.watcherReset: "استعادة الافتراضي",
        NetLensTranslationKey.watcherResetConfirm:
            "استبدال كل حقول المراقبة بالحقول الافتراضية؟",
        NetLensTranslationKey.watcherNoFields: "لا توجد حقول مراقبة بعد",
        NetLensTranslationKey.watcherNoValues: "لا توجد قيم بعد",
        NetLensTranslationKey.watcherOutcomeSuccess: "نجاح",
        NetLensTranslationKey.watcherOutcomeFailed: "فشل",
        NetLensTranslationKey.watcherOutcomeServerDown: "الخادم متوقف",
        NetLensTranslationKey.issueReasonWatchFailed:
            "تشير الاستجابة إلى فشل رغم أن حالة HTTP سليمة: [error]",
        NetLensTranslationKey.issueReasonWatchServerDown:
            "تشير الاستجابة إلى أن الخادم متوقف رغم أن حالة HTTP سليمة: "
            "[error]",
        NetLensTranslationKey.callErrorScreenType: "النوع",
        NetLensTranslationKey.callResponseBodyUnsupportedTitle:
            "محتوى غير مدعوم",
        NetLensTranslationKey.callResponseBodyUnsupportedDescription:
            "يمكن لـ NetLens عرض JSON وXML والنصوص والصور والفيديو. نوع "
            "المحتوى [contentType] لهذه الاستجابة لا يمكن معاينته.",
        NetLensTranslationKey.callResponseBodyUnsupportedWarning:
            "يمكنك محاولة عرض المحتوى كنص خام، لكنه قد يكون غير مقروء.",
        NetLensTranslationKey.callDetailsRevealSensitive: "إظهار القيم المخفية",
        NetLensTranslationKey.callDetailsHideSensitive: "إخفاء القيم الحساسة",
        NetLensTranslationKey.filtersFailed: "فشل",
        NetLensTranslationKey.filtersPending: "قيد الانتظار",
        NetLensTranslationKey.filtersHost: "الخادم",
        NetLensTranslationKey.filtersAllHosts: "كل الخوادم",
        NetLensTranslationKey.filtersClear: "مسح الفلاتر",
        NetLensTranslationKey.callsListNoFilterResults:
            "لا توجد طلبات تطابق الفلاتر",
        NetLensTranslationKey.replayAction: "تعديل وإعادة الإرسال",
        NetLensTranslationKey.replayMethod: "الطريقة",
        NetLensTranslationKey.replayUrl: "الرابط",
        NetLensTranslationKey.replayHeaders: "الترويسات",
        NetLensTranslationKey.replayHeadersHint:
            "ترويسة واحدة في كل سطر، بالشكل الاسم: القيمة",
        NetLensTranslationKey.replayBody: "المحتوى",
        NetLensTranslationKey.replaySend: "إرسال",
        NetLensTranslationKey.replayReset: "إعادة التعيين",
        NetLensTranslationKey.replaySent:
            "تم إرسال الطلب. الطلب الجديد في أعلى القائمة.",
        NetLensTranslationKey.replayFailed: "تعذر إرسال الطلب: [error]",
        NetLensTranslationKey.replayFormDataWarning:
            "أرسل هذا الطلب بيانات نموذج. يحتفظ NetLens بأسماء البيانات وأحجامها فقط، لذلك المحتوى فارغ.",
        NetLensTranslationKey.replayInvalidUrl:
            "أدخل رابطًا كاملًا، مثل https://api.example.com/users",
        NetLensTranslationKey.replayInvalidHeader:
            "السطر [line] ليس ترويسة. استخدم الاسم: القيمة.",
        NetLensTranslationKey.jsonViewTree: "شجرة",
        NetLensTranslationKey.jsonViewRaw: "نص خام",
        NetLensTranslationKey.jsonSearchHint: "ابحث في المفاتيح والقيم",
        NetLensTranslationKey.jsonExpandAll: "توسيع الكل",
        NetLensTranslationKey.jsonCollapseAll: "طي الكل",
        NetLensTranslationKey.jsonCopyValue: "نسخ القيمة",
        NetLensTranslationKey.jsonCopyPath: "نسخ المسار",
        NetLensTranslationKey.jsonMatches: "عدد النتائج: [count]",
        NetLensTranslationKey.jsonNoMatches: "لا توجد نتائج",
        NetLensTranslationKey.callsListExportHar: "تصدير HAR",
        NetLensTranslationKey.callOverviewGraphQL: "GraphQL:",
        NetLensTranslationKey.graphQLErrors: "أخطاء GraphQL",
        NetLensTranslationKey.callsListTimeline: "المخطط الزمني",
        NetLensTranslationKey.timelineEmpty: "لا توجد طلبات لعرضها بعد",
        NetLensTranslationKey.timelineSummary:
            "[count] طلب خلال [duration]، وحتى [concurrency] في الوقت نفسه",
        NetLensTranslationKey.statsSectionSlowest: "أبطأ نقاط النهاية",
        NetLensTranslationKey.statsEndpointCalls: "عدد الطلبات: [count]",
        NetLensTranslationKey.statsEndpointFailures: "فشل: [count]",
      },
    );
  }

  /// Returns localized value for specific [languageCode] and [key]. English
  /// is used when language or key is not translated. If value can't be
  /// selected then [key] will be returned.
  static String get({
    required String languageCode,
    required NetLensTranslationKey key,
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
