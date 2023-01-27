import 'dart:ffi';

import 'package:conduit/conduit.dart';

class Finances extends ManagedObject<_Finances> implements _Finances {}

class _Finances{
  @primaryKey
  int? id;

  @Column(unique:true)
  String? number;

  @Column()
  String? nameOperation;

  @Column()
  String? description;

  @Column()
  String? kategory;

  @Column()
  String? dateOperation;

  @Column()
  int? summ;

  @Column(defaultValue: "false", nullable: true)
  bool? isdeleted;
}