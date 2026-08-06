import 'assistant_intent.dart';

abstract class IntentClassifier {
  AssistantIntent classify(String message);
}
