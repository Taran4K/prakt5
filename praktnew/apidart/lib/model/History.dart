import 'dart:ffi';

import 'package:conduit/conduit.dart';

class History extends ManagedObject<_History> implements _History {}

class _History{
  @primaryKey
  int? id;

  @Column()
  int? numid;

  @Column()
  String? description;

  @Column()
  String? dateOperation;
}