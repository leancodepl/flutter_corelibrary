import { WindowMessenger, connect, Methods } from "penpal";

declare global {
  var __contract__connectToHost: (
    methods: Methods,
    allowedOrigins?: string[],
  ) => Promise<
    | { status: "connected"; destroy: () => void; host: object }
    | { status: "error"; destroy: () => void; error: Error }
  >;
}

globalThis.__contract__connectToHost = async (
  methods: Methods,
  allowedOrigins?: string[],
) => {
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
      status: "connected" as const,
      destroy,
      host: proxy,
    };
  } catch (error) {
    return {
      status: "error" as const,
      destroy,
      error: error instanceof Error ? error : new Error(String(error)),
    };
  }
};
