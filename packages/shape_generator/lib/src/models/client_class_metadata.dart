import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/type_visitor.dart';
import 'package:analyzer/dart/element/visitor.dart';

/// Metadata about a constructor or factory method in the client codebase.
class ClientClassMetadata {
  const ClientClassMetadata._({
    required this.baseType,
    this.supertype,
    this.instanceType,
    required this.isAbstract,
    required this.isEnum,
    required this.isMixin,
    required this.constructors,
    required this.fields,
    required this.methods,
    required this.typeParameters,
  });

  factory ClientClassMetadata.fromElement(
    Element element, {
    DartType? withInstanceType,
  }) {
    if (element is! ClassElement) {
      throw Exception('Expected a ClassElement.');
    }

    final classVisitor = _DefaultClassVisitor();
    element.visitChildren(classVisitor);

    final typeVisitor = _DefaultTypeVisitor();
    element.thisType.accept(typeVisitor);

    return ClientClassMetadata._(
      baseType: element.thisType,
      supertype: element.supertype,
      instanceType: withInstanceType ?? typeVisitor.type,
      isAbstract: element.isAbstract,
      isEnum: element is EnumElement,
      isMixin: element is MixinElement,
      constructors: classVisitor.constructors
          .where((constructor) => !constructor.isSynthetic)
          .toList(),
      fields: classVisitor.fields,
      methods: classVisitor.methods,
      typeParameters: classVisitor.typeParameters,
    );
  }

  final InterfaceType baseType; // GenericFormField<T>
  final InterfaceType?
      supertype; // FormField<T?, T?, GenericFormFieldValidationError>
  final DartType? instanceType; // GenericFormField<int>
  final bool isAbstract;
  final bool isEnum;
  final bool isMixin;
  final List<ConstructorElement> constructors;
  final Map<String, DartType> fields;
  final List<ClientClassMethodMetadata> methods;
  final List<TypeParameterElement> typeParameters;

  String get name => baseType.getDisplayString(withNullability: false);

  bool get isValid => isAbstract && !isEnum && !isMixin;

  @override
  String toString() {
    return 'ClientClassMetadata(baseType: $baseType, supertype: $supertype, instanceType: $instanceType, isAbstract: $isAbstract, isEnum: $isEnum, isMixin: $isMixin, constructors: $constructors, fields: $fields, methods: $methods, typeParameters: $typeParameters)';
  }
}

class ClientClassMethodMetadata {
  const ClientClassMethodMetadata._({
    required this.name,
    required this.returnType,
    required this.parameters,
    required this.isAbstract,
    required this.isStatic,
    required this.hasOverride,
  });

  final String name;
  final DartType returnType;
  final List<ParameterElement> parameters;
  final bool isAbstract;
  final bool isStatic;
  final bool hasOverride;

  @override
  String toString() {
    return 'ClientClassMethodMetadata(name: $name, returnType: $returnType, parameters: $parameters, isAbstract: $isAbstract, isStatic: $isStatic, hasOverride: $hasOverride)';
  }
}

class _DefaultClassVisitor extends SimpleElementVisitor<dynamic> {
  final constructors = <ConstructorElement>[];
  final fields = <String, DartType>{};
  final methods = <ClientClassMethodMetadata>[];
  final typeParameters = <TypeParameterElement>[];

  @override
  dynamic visitConstructorElement(ConstructorElement element) {
    constructors.add(element);
    return super.visitConstructorElement(element);
  }

  @override
  dynamic visitFieldElement(FieldElement element) {
    fields[element.name] = element.type;

    return super.visitFieldElement(element);
  }

  @override
  dynamic visitTypeParameterElement(TypeParameterElement element) {
    typeParameters.add(element);
    return super.visitTypeParameterElement(element);
  }

  @override
  dynamic visitMethodElement(MethodElement element) {
    methods.add(
      ClientClassMethodMetadata._(
        name: element.name,
        returnType: element.returnType,
        parameters: element.parameters,
        isAbstract: element.isAbstract,
        isStatic: element.isStatic,
        hasOverride: element.hasOverride,
      ),
    );
    return super.visitMethodElement(element);
  }
}

class _DefaultTypeVisitor extends TypeVisitor<void> {
  final _types = <DartType>[];
  DartType? get type => _types.isEmpty ? null : _types.last;

  @override
  void visitDynamicType(DynamicType type) {
    _types.add(type);
  }

  @override
  void visitFunctionType(FunctionType type) {
    _types.add(type);
  }

  @override
  void visitInterfaceType(InterfaceType type) {
    _types.add(type);
  }

  @override
  void visitNeverType(NeverType type) {
    _types.add(type);
  }

  @override
  void visitTypeParameterType(TypeParameterType type) {
    _types.add(type);
  }

  @override
  void visitVoidType(VoidType type) {
    _types.add(type);
  }

  @override
  void visitRecordType(RecordType type) {
    _types.add(type);
  }

  @override
  void visitInvalidType(InvalidType type) {
    _types.add(type);
  }
}
