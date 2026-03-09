import {
  WindowMessenger,
  connect,
} from "https://unpkg.com/penpal@7/dist/penpal.mjs";

globalThis.__contract__connectToHost = async (methods, allowedOrigins) => {
  const parentOrigin =
    document.referrer && document.referrer !== ""
      ? new URL(document.referrer).origin
      : globalThis.location.origin;

  const messenger = new WindowMessenger({
    remoteWindow: globalThis.window.parent,
    allowedOrigins: allowedOrigins ?? [parentOrigin],
  });

  const { promise, destroy } = connect({
    messenger,
    methods,
  });

  try {
    const proxy = await promise;

    return {
      status: "connected",
      destroy,
      host: proxy,
    };
  } catch (error) {
    return {
      status: "error",
      destroy,
      error: error instanceof Error ? error : new Error(String(error)),
    };
  }
};
