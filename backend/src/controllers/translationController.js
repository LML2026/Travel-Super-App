const createPostTranslation = ({ DEEPL_API_KEY, DEEPL_API_HOST, httpsJsonRequest }) => {
  return async (req, res) => {
    const {
      text,
      sourceLanguageCode = 'auto',
      targetLanguageCode,
      autoDetect = false,
    } = req.body || {};

    if (
      typeof text !== 'string' ||
      !text.trim() ||
      typeof targetLanguageCode !== 'string' ||
      !targetLanguageCode.trim()
    ) {
      return res.status(400).json({
        error: 'Translation text and target language are required.',
      });
    }

    if (!DEEPL_API_KEY) {
      return res.status(503).json({
        error: 'Translation provider is not configured.',
      });
    }

    const source = sourceLanguageCode === 'auto' || autoDetect
      ? undefined
      : sourceLanguageCode.trim().toUpperCase();
    const target = deepLTargetLanguage(targetLanguageCode);
    const body = {
      text: [text.trim()],
      target_lang: target,
      ...(source ? { source_lang: source } : {}),
    };

    try {
      const response = await httpsJsonRequest(
        {
          hostname: DEEPL_API_HOST,
          path: '/v2/translate',
          method: 'POST',
          headers: {
            Authorization: `DeepL-Auth-Key ${DEEPL_API_KEY}`,
            'Content-Type': 'application/json',
            Accept: 'application/json',
          },
        },
        body,
        1,
      );
      const translation = response?.translations?.[0];
      if (!translation?.text) {
        return res.status(502).json({
          error: 'Translation provider returned no result.',
        });
      }

      return res.json({
        translatedText: translation.text,
        sourceLanguageCode:
          translation.detected_source_language?.toLowerCase() || sourceLanguageCode,
        targetLanguageCode: targetLanguageCode.trim().toLowerCase(),
        detectedLanguageCode:
          translation.detected_source_language?.toLowerCase(),
        source: 'deepl',
      });
    } catch (_) {
      return res.status(502).json({
        error: 'Translation provider is temporarily unavailable.',
      });
    }
  };
};

const deepLTargetLanguage = (languageCode) => {
  const normalized = languageCode.trim().toLowerCase();
  const mapped = {
    en: 'EN-GB',
    pt: 'PT-PT',
  };
  return mapped[normalized] || normalized.toUpperCase();
};

module.exports = { createPostTranslation };
