## 0.1.1+2

 - **FIX**(openai_dart): Decode JSON responses as UTF-8 ([#234](https://github.com/davidmigloz/langchain_dart/issues/234)). ([0bca67f4](https://github.com/davidmigloz/langchain_dart/commit/0bca67f4ea682ebd5a8b9d3c7319c9511229b0ba))

## 0.1.1+1

 - **FIX**(openai_dart): Fetch requests with big payloads dropping connection ([#226](https://github.com/davidmigloz/langchain_dart/issues/226)). ([1e771098](https://github.com/davidmigloz/langchain_dart/commit/1e771098d1090dd79846fca6520a1195efc5ac1e))

## 0.1.1

 - **FEAT**(openai_dart): Add Azure OpenAI API support ([#224](https://github.com/davidmigloz/langchain_dart/issues/224)). ([333fb7af](https://github.com/davidmigloz/langchain_dart/commit/333fb7af4b1edbdc716221609f2dc8f3923822cf))

## 0.1.0+1

 - **FIX**(openai_dart): Add missing `name` param in ChatCompletionMessage ([#222](https://github.com/davidmigloz/langchain_dart/issues/222)). ([6f186775](https://github.com/davidmigloz/langchain_dart/commit/6f186775f67cf3db5e28e4a15f896927b9af50ce))
 - **FIX**(openai_dart): Remove dependency on io.HttpException ([#221](https://github.com/davidmigloz/langchain_dart/issues/221)). ([95369e4c](https://github.com/davidmigloz/langchain_dart/commit/95369e4c1a9b8f277390b612df7d9bb21c19d82f))
 - **DOCS**: Add public_member_api_docs lint rule and document missing APIs ([#223](https://github.com/davidmigloz/langchain_dart/issues/223)). ([52380433](https://github.com/davidmigloz/langchain_dart/commit/523804331783970870b023946c016be6c0797920))

## 0.1.0

> Note: This release has breaking changes.
> Migration guides: [new factories](https://github.com/davidmigloz/langchain_dart/issues/215) and [multi-modal](https://github.com/davidmigloz/langchain_dart/issues/218)

 - **BREAKING** **FEAT**(openai_dart): Add multi-modal support ([#218](https://github.com/davidmigloz/langchain_dart/issues/218)). ([14c8e7ef](https://github.com/davidmigloz/langchain_dart/commit/14c8e7ef7194400057d40422822df1127c4cb131))
 - **BREAKING** **FEAT**(openai_dart): Rename factory const to more meaningful names ([#215](https://github.com/davidmigloz/langchain_dart/issues/215)). ([7e4602fa](https://github.com/davidmigloz/langchain_dart/commit/7e4602fa86c55bd6d82a0aac253b1165afa21aeb))
 - **FEAT**(openai_dart): Add gpt-3.5-turbo-1106 chat model ([#217](https://github.com/davidmigloz/langchain_dart/issues/217)). ([73f37915](https://github.com/davidmigloz/langchain_dart/commit/73f37915e99d83bd458f8f8500385a24a64d3948))
 - **REFACTOR**(openai_dart): Improve request error handling ([#214](https://github.com/davidmigloz/langchain_dart/issues/214)). ([4a9f3d33](https://github.com/davidmigloz/langchain_dart/commit/4a9f3d335124526438651149e5b91c07921617a2))

## 0.0.2+2

 - **REFACTOR**(openai_dart): Migrate to generated client stream methods ([#208](https://github.com/davidmigloz/langchain_dart/issues/208)). ([9122f551](https://github.com/davidmigloz/langchain_dart/commit/9122f5517bb12a9596d22acfa6e81251f6d9afe8))
 - **FIX**(openai_dart): Fix integer overflow when targeting web ([#207](https://github.com/davidmigloz/langchain_dart/issues/207)). ([eaf69f32](https://github.com/davidmigloz/langchain_dart/commit/eaf69f32266abe4c8a4c99502fe9b1be2029d7d1))

## 0.0.2+1

 - **REFACTOR**(openai_dart): Rename ChatCompletionFunction to FunctionObject ([#206](https://github.com/davidmigloz/langchain_dart/issues/206)). ([0f06df3f](https://github.com/davidmigloz/langchain_dart/commit/0f06df3f9b32e5887976936b5fd2e6aa5a4f4f5b))

## 0.0.2

 - **FEAT**(openai_dart): Support new models API functionality ([#203](https://github.com/davidmigloz/langchain_dart/issues/203)). ([33ebe746](https://github.com/davidmigloz/langchain_dart/commit/33ebe746b509009ba41e417f36abf267d9d1c2ca))
 - **FEAT**(openai_dart): Support new images API functionality ([#202](https://github.com/davidmigloz/langchain_dart/issues/202)). ([fcf21daf](https://github.com/davidmigloz/langchain_dart/commit/fcf21dafbbdf4b1598ed8ddbfe30ebd09da65ada))
 - **FEAT**(openai_dart): Support new fine-tunning API functionality ([#201](https://github.com/davidmigloz/langchain_dart/issues/201)). ([f5f44ad8](https://github.com/davidmigloz/langchain_dart/commit/f5f44ad831c87c71ad995567748546b82ee231a4))
 - **FEAT**(openai_dart): Support new embeddings API functionality ([#200](https://github.com/davidmigloz/langchain_dart/issues/200)). ([9b43d85b](https://github.com/davidmigloz/langchain_dart/commit/9b43d85b63ddf916c38e7c5d7c65d5be32fa3015))
 - **FEAT**(openai_dart): Support new completion API functionality ([#199](https://github.com/davidmigloz/langchain_dart/issues/199)). ([f12f6f57](https://github.com/davidmigloz/langchain_dart/commit/f12f6f577c0e74db6160101796522c8786c4f37e))
 - **FEAT**(openai_dart): Support new chat completion API functionality ([#198](https://github.com/davidmigloz/langchain_dart/issues/198)). ([01820d69](https://github.com/davidmigloz/langchain_dart/commit/01820d697c9ffac09f77d2a16a5db6b5e6ed6fc6))
 - **FIX**(openai_dart): Handle nullable function call fields when streaming ([#191](https://github.com/davidmigloz/langchain_dart/issues/191)). ([8f23cf16](https://github.com/davidmigloz/langchain_dart/commit/8f23cf16c96f73d69a2abf17f2142b7eb4922a73))

## 0.0.1

 - **FIX**(openai_dart): Fix static analysis warning ([#187](https://github.com/davidmigloz/langchain_dart/issues/187)). ([3fe91570](https://github.com/davidmigloz/langchain_dart/commit/3fe915705ca5a8b335333fa5ea94260040aaf0db))
 - **FIX**(openai_dart): Several fixes and improvments ([#182](https://github.com/davidmigloz/langchain_dart/issues/182)). ([115e8bef](https://github.com/davidmigloz/langchain_dart/commit/115e8bef43c82d907ce94518fa382657a1237fcc))
 - **FEAT**(openai_dart): Support different embedding response formats ([#180](https://github.com/davidmigloz/langchain_dart/issues/180)). ([4f676e87](https://github.com/davidmigloz/langchain_dart/commit/4f676e875f05a837343792c976701fa0cda0076e))
 - **FEAT**(openai_dart): Implement openai_dart, a Dart client for OpenAI API ([#178](https://github.com/davidmigloz/langchain_dart/issues/178)). ([fa5d032a](https://github.com/davidmigloz/langchain_dart/commit/fa5d032a6225933a79d4ff039732d893156ac92d))

## 0.0.1-dev.1

- Bootstrap project
