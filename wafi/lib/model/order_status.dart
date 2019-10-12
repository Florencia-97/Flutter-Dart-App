class OrderStatuses {
  static const String Requested = "requested";
  static const String Taken = "taken";
  static const String Cancelled = "cancelled";
  static const String Resolved = "resolved";

  static get values => [Requested, Taken, Cancelled, Resolved];
}
