// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'artwork.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Artwork {

 int get id; String get title; double get progress; ArtworkStatus get status;/// PNG-превью для карточки галереи.
 Uint8List? get thumbnail; String? get sourcePdfPath; int get pageIndex;
/// Create a copy of Artwork
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ArtworkCopyWith<Artwork> get copyWith => _$ArtworkCopyWithImpl<Artwork>(this as Artwork, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Artwork&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.thumbnail, thumbnail)&&(identical(other.sourcePdfPath, sourcePdfPath) || other.sourcePdfPath == sourcePdfPath)&&(identical(other.pageIndex, pageIndex) || other.pageIndex == pageIndex));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,progress,status,const DeepCollectionEquality().hash(thumbnail),sourcePdfPath,pageIndex);

@override
String toString() {
  return 'Artwork(id: $id, title: $title, progress: $progress, status: $status, thumbnail: $thumbnail, sourcePdfPath: $sourcePdfPath, pageIndex: $pageIndex)';
}


}

/// @nodoc
abstract mixin class $ArtworkCopyWith<$Res>  {
  factory $ArtworkCopyWith(Artwork value, $Res Function(Artwork) _then) = _$ArtworkCopyWithImpl;
@useResult
$Res call({
 int id, String title, double progress, ArtworkStatus status, Uint8List? thumbnail, String? sourcePdfPath, int pageIndex
});




}
/// @nodoc
class _$ArtworkCopyWithImpl<$Res>
    implements $ArtworkCopyWith<$Res> {
  _$ArtworkCopyWithImpl(this._self, this._then);

  final Artwork _self;
  final $Res Function(Artwork) _then;

/// Create a copy of Artwork
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? progress = null,Object? status = null,Object? thumbnail = freezed,Object? sourcePdfPath = freezed,Object? pageIndex = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ArtworkStatus,thumbnail: freezed == thumbnail ? _self.thumbnail : thumbnail // ignore: cast_nullable_to_non_nullable
as Uint8List?,sourcePdfPath: freezed == sourcePdfPath ? _self.sourcePdfPath : sourcePdfPath // ignore: cast_nullable_to_non_nullable
as String?,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Artwork].
extension ArtworkPatterns on Artwork {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Artwork value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Artwork() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Artwork value)  $default,){
final _that = this;
switch (_that) {
case _Artwork():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Artwork value)?  $default,){
final _that = this;
switch (_that) {
case _Artwork() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String title,  double progress,  ArtworkStatus status,  Uint8List? thumbnail,  String? sourcePdfPath,  int pageIndex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Artwork() when $default != null:
return $default(_that.id,_that.title,_that.progress,_that.status,_that.thumbnail,_that.sourcePdfPath,_that.pageIndex);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String title,  double progress,  ArtworkStatus status,  Uint8List? thumbnail,  String? sourcePdfPath,  int pageIndex)  $default,) {final _that = this;
switch (_that) {
case _Artwork():
return $default(_that.id,_that.title,_that.progress,_that.status,_that.thumbnail,_that.sourcePdfPath,_that.pageIndex);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String title,  double progress,  ArtworkStatus status,  Uint8List? thumbnail,  String? sourcePdfPath,  int pageIndex)?  $default,) {final _that = this;
switch (_that) {
case _Artwork() when $default != null:
return $default(_that.id,_that.title,_that.progress,_that.status,_that.thumbnail,_that.sourcePdfPath,_that.pageIndex);case _:
  return null;

}
}

}

/// @nodoc


class _Artwork implements Artwork {
  const _Artwork({required this.id, required this.title, this.progress = 0, this.status = ArtworkStatus.fresh, this.thumbnail, this.sourcePdfPath, this.pageIndex = 0});
  

@override final  int id;
@override final  String title;
@override@JsonKey() final  double progress;
@override@JsonKey() final  ArtworkStatus status;
/// PNG-превью для карточки галереи.
@override final  Uint8List? thumbnail;
@override final  String? sourcePdfPath;
@override@JsonKey() final  int pageIndex;

/// Create a copy of Artwork
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ArtworkCopyWith<_Artwork> get copyWith => __$ArtworkCopyWithImpl<_Artwork>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Artwork&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.thumbnail, thumbnail)&&(identical(other.sourcePdfPath, sourcePdfPath) || other.sourcePdfPath == sourcePdfPath)&&(identical(other.pageIndex, pageIndex) || other.pageIndex == pageIndex));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,progress,status,const DeepCollectionEquality().hash(thumbnail),sourcePdfPath,pageIndex);

@override
String toString() {
  return 'Artwork(id: $id, title: $title, progress: $progress, status: $status, thumbnail: $thumbnail, sourcePdfPath: $sourcePdfPath, pageIndex: $pageIndex)';
}


}

/// @nodoc
abstract mixin class _$ArtworkCopyWith<$Res> implements $ArtworkCopyWith<$Res> {
  factory _$ArtworkCopyWith(_Artwork value, $Res Function(_Artwork) _then) = __$ArtworkCopyWithImpl;
@override @useResult
$Res call({
 int id, String title, double progress, ArtworkStatus status, Uint8List? thumbnail, String? sourcePdfPath, int pageIndex
});




}
/// @nodoc
class __$ArtworkCopyWithImpl<$Res>
    implements _$ArtworkCopyWith<$Res> {
  __$ArtworkCopyWithImpl(this._self, this._then);

  final _Artwork _self;
  final $Res Function(_Artwork) _then;

/// Create a copy of Artwork
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? progress = null,Object? status = null,Object? thumbnail = freezed,Object? sourcePdfPath = freezed,Object? pageIndex = null,}) {
  return _then(_Artwork(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ArtworkStatus,thumbnail: freezed == thumbnail ? _self.thumbnail : thumbnail // ignore: cast_nullable_to_non_nullable
as Uint8List?,sourcePdfPath: freezed == sourcePdfPath ? _self.sourcePdfPath : sourcePdfPath // ignore: cast_nullable_to_non_nullable
as String?,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
