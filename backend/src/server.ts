import { initializeApp } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";
import { createApp } from "./app";
import { TokenVerifier } from "./auth/auth_middleware";
import { createConfiguredTranslationProvider } from "./translation/translation_provider_factory";
import { createConfiguredTimezoneProvider } from "./timezone/timezone_provider_factory";

initializeApp();

const tokenVerifier: TokenVerifier = {
  async verifyIdToken(token) {
    const decoded = await getAuth().verifyIdToken(token);
    return { uid: decoded.uid };
  },
};

const port = Number(process.env.PORT ?? 8080);
createApp({
  tokenVerifier,
  provider: createConfiguredTranslationProvider(),
  timezoneProvider: createConfiguredTimezoneProvider(),
}).listen(port, () => {
  console.log(`ITAREVO backend listening on port ${port}`);
});
