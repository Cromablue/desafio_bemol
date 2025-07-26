class SupportedCode {
  final String code;
  final String name;

  SupportedCode({required this.code, required this.name});

  factory SupportedCode.fromList(List<dynamic> list) {
    return SupportedCode(
      code: list[0],
      name: list[1],
    );
  }
}