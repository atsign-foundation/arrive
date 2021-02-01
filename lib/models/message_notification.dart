import 'dart:convert';

class MessageNotificationModel {
  String content;
  bool acknowledged;
  DateTime timeStamp;
  MessageNotificationModel({this.content, this.acknowledged, this.timeStamp});
  MessageNotificationModel.fromJson(Map<String, dynamic> json)
      : content = json['content'] ?? '',
        acknowledged = json['acknowledged'] == 'true' ? true : false,
        timeStamp = DateTime.parse(json['timeStamp']) ?? DateTime.now();
  Map<String, dynamic> toJson() => {
        'content': content,
        'acknowledged': acknowledged,
        'timeStamp': timeStamp,
      };

  static String convertMessageNotificationToJson(
      MessageNotificationModel messageNotificationModel) {
    var notification = json.encode({
      'content': messageNotificationModel.content,
      'acknowledged': messageNotificationModel.acknowledged.toString(),
      'timeStamp': messageNotificationModel.timeStamp.toString()
    });
    return notification;
  }
}
