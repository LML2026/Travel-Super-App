import { initializeApp } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";
import { createApp } from "./app";
import { TokenVerifier } from "./auth/auth_middleware";

initializeApp();

const tokenVerifier: TokenVerifier = {
  async verifyIdToken(token) {
    const decoded = await getAuth().verifyIdToken(token);
    return { uid: decoded.uid };
  },
};

const port = Number(process.env.PORT ?? 8080);
createApp({ tokenVerifier }).listen(port, () => {
  console.log(`ITAREVO backend listening on port ${port}`);
});
