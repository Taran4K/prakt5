import 'package:flutter/cupertino.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User{
  const factory User({
    @JsonKey(name: "userName")
    required String username,
    required String email,
    required String password,
  })= _User;

  factory User.fromJson(Map<String, dynamic> json)=> _$UserFromJson(json);
}