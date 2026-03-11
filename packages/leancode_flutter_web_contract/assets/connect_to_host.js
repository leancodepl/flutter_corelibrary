var ve = Object.defineProperty;
var B = (e) => {
  throw TypeError(e);
};
var ye = (e, t, r) => t in e ? ve(e, t, { enumerable: !0, configurable: !0, writable: !0, value: r }) : e[t] = r;
var I = (e, t, r) => ye(e, typeof t != "symbol" ? t + "" : t, r), Q = (e, t, r) => t.has(e) || B("Cannot " + r);
var s = (e, t, r) => (Q(e, t, "read from private field"), r ? r.call(e) : t.get(e)), p = (e, t, r) => t.has(e) ? B("Cannot add the same private member more than once") : t instanceof WeakSet ? t.add(e) : t.set(e, r), S = (e, t, r, a) => (Q(e, t, "write to private field"), a ? a.call(e, r) : t.set(e, r), r);
var Me = class extends Error {
  constructor(t, r) {
    super(r);
    I(this, "code");
    this.name = "PenpalError", this.code = t;
  }
}, v = Me, Ee = (e) => ({
  name: e.name,
  message: e.message,
  stack: e.stack,
  penpalCode: e instanceof v ? e.code : void 0
}), we = ({
  name: e,
  message: t,
  stack: r,
  penpalCode: a
}) => {
  const n = a ? new v(a, t) : new Error(t);
  return n.name = e, n.stack = r, n;
}, Ie = Symbol("Reply"), G, ne, Se = (ne = class {
  constructor(e, t) {
    I(this, "value");
    I(this, "transferables");
    // Allows TypeScript to distinguish between an actual instance of this
    // class versus an object that looks structurally similar.
    // eslint-disable-next-line no-unused-private-class-members
    p(this, G, Ie);
    this.value = e, this.transferables = t == null ? void 0 : t.transferables;
  }
}, G = new WeakMap(), ne), Ae = Se, E = "penpal", V = (e) => typeof e == "object" && e !== null, oe = (e) => typeof e == "function", Pe = (e) => V(e) && e.namespace === E, Y = (e) => e.type === "SYN", X = (e) => e.type === "ACK1", z = (e) => e.type === "ACK2", de = (e) => e.type === "CALL", ce = (e) => e.type === "REPLY", Re = (e) => e.type === "DESTROY", le = (e, t = []) => {
  const r = [];
  for (const a of Object.keys(e)) {
    const n = e[a];
    oe(n) ? r.push([...t, a]) : V(n) && r.push(
      ...le(n, [...t, a])
    );
  }
  return r;
}, me = (e, t) => {
  const r = e.reduce(
    (a, n) => V(a) ? a[n] : void 0,
    t
  );
  return oe(r) ? r : void 0;
}, m = (e) => e.join("."), Z = (e, t, r) => ({
  namespace: E,
  channel: e,
  type: "REPLY",
  callId: t,
  isError: !0,
  ...r instanceof Error ? { value: Ee(r), isSerializedErrorInstance: !0 } : { value: r }
}), Ne = (e, t, r, a) => {
  let n = !1;
  const c = async (d) => {
    if (n || !de(d))
      return;
    a == null || a(`Received ${m(d.methodPath)}() call`, d);
    const { methodPath: y, args: u, id: i } = d;
    let o, w;
    try {
      const h = me(y, t);
      if (!h)
        throw new v(
          "METHOD_NOT_FOUND",
          `Method \`${m(y)}\` is not found.`
        );
      let f = await h(...u);
      f instanceof Ae && (w = f.transferables, f = await f.value), o = {
        namespace: E,
        channel: r,
        type: "REPLY",
        callId: i,
        value: f
      };
    } catch (h) {
      o = Z(r, i, h);
    }
    if (!n)
      try {
        a == null || a(`Sending ${m(y)}() reply`, o), e.sendMessage(o, w);
      } catch (h) {
        throw h.name === "DataCloneError" && (o = Z(r, i, h), a == null || a(`Sending ${m(y)}() reply`, o), e.sendMessage(o)), h;
      }
  };
  return e.addMessageHandler(c), () => {
    n = !0, e.removeMessageHandler(c);
  };
}, Ce = Ne, ae, ue = ((ae = crypto.randomUUID) == null ? void 0 : ae.bind(crypto)) ?? (() => new Array(4).fill(0).map(
  () => Math.floor(Math.random() * Number.MAX_SAFE_INTEGER).toString(16)
).join("-")), _e = Symbol("CallOptions"), J, se, Te = (se = class {
  constructor(e) {
    I(this, "transferables");
    I(this, "timeout");
    // Allows TypeScript to distinguish between an actual instance of this
    // class versus an object that looks structurally similar.
    // eslint-disable-next-line no-unused-private-class-members
    p(this, J, _e);
    this.transferables = e == null ? void 0 : e.transferables, this.timeout = e == null ? void 0 : e.timeout;
  }
}, J = new WeakMap(), se), be = Te, Le = /* @__PURE__ */ new Set(["apply", "call", "bind"]), he = (e, t, r = []) => new Proxy(
  r.length ? () => {
  } : /* @__PURE__ */ Object.create(null),
  {
    get(a, n) {
      if (n !== "then")
        return r.length && Le.has(n) ? Reflect.get(a, n) : he(e, t, [...r, n]);
    },
    apply(a, n, c) {
      return e(r, c);
    }
  }
), ee = (e) => new v(
  "CONNECTION_DESTROYED",
  `Method call ${m(
    e
  )}() failed due to destroyed connection`
), De = (e, t, r) => {
  let a = !1;
  const n = /* @__PURE__ */ new Map(), c = (u) => {
    if (!ce(u))
      return;
    const { callId: i, value: o, isError: w, isSerializedErrorInstance: h } = u, f = n.get(i);
    f && (n.delete(i), r == null || r(
      `Received ${m(f.methodPath)}() call`,
      u
    ), w ? f.reject(
      h ? we(o) : o
    ) : f.resolve(o));
  };
  return e.addMessageHandler(c), {
    remoteProxy: he((u, i) => {
      if (a)
        throw ee(u);
      const o = ue(), w = i[i.length - 1], h = w instanceof be, { timeout: f, transferables: K } = h ? w : {}, x = h ? i.slice(0, -1) : i;
      return new Promise(($, k) => {
        const g = f !== void 0 ? window.setTimeout(() => {
          n.delete(o), k(
            new v(
              "METHOD_CALL_TIMEOUT",
              `Method call ${m(
                u
              )}() timed out after ${f}ms`
            )
          );
        }, f) : void 0;
        n.set(o, { methodPath: u, resolve: $, reject: k, timeoutId: g });
        try {
          const b = {
            namespace: E,
            channel: t,
            type: "CALL",
            id: o,
            methodPath: u,
            args: x
          };
          r == null || r(`Sending ${m(u)}() call`, b), e.sendMessage(b, K);
        } catch (b) {
          k(
            new v("TRANSMISSION_FAILED", b.message)
          );
        }
      });
    }, r),
    destroy: () => {
      a = !0, e.removeMessageHandler(c);
      for (const { methodPath: u, reject: i, timeoutId: o } of n.values())
        clearTimeout(o), i(ee(u));
      n.clear();
    }
  };
}, Oe = De, ke = () => {
  let e, t;
  return {
    promise: new Promise((a, n) => {
      e = a, t = n;
    }),
    resolve: e,
    reject: t
  };
}, He = ke, W = "deprecated-penpal", Fe = (e) => V(e) && "penpal" in e, xe = (e) => e.split("."), te = (e) => e.join("."), $e = (e) => {
  try {
    return JSON.stringify(e);
  } catch {
    return String(e);
  }
}, fe = (e) => new v(
  "TRANSMISSION_FAILED",
  `Unexpected message to translate: ${$e(e)}`
), Ue = (e) => {
  if (e.penpal === "syn")
    return {
      namespace: E,
      channel: void 0,
      type: "SYN",
      participantId: W
    };
  if (e.penpal === "ack")
    return {
      namespace: E,
      channel: void 0,
      type: "ACK2"
    };
  if (e.penpal === "call")
    return {
      namespace: E,
      channel: void 0,
      type: "CALL",
      // Actually converting the ID to a string would break communication.
      id: e.id,
      methodPath: xe(e.methodName),
      args: e.args
    };
  if (e.penpal === "reply")
    return e.resolution === "fulfilled" ? {
      namespace: E,
      channel: void 0,
      type: "REPLY",
      // Actually converting the ID to a string would break communication.
      callId: e.id,
      value: e.returnValue
    } : {
      namespace: E,
      channel: void 0,
      type: "REPLY",
      // Actually converting the ID to a string would break communication.
      callId: e.id,
      isError: !0,
      ...e.returnValueIsError ? {
        value: e.returnValue,
        isSerializedErrorInstance: !0
      } : {
        value: e.returnValue
      }
    };
  throw fe(e);
}, Ye = (e) => {
  if (X(e))
    return {
      penpal: "synAck",
      methodNames: e.methodPaths.map(te)
    };
  if (de(e))
    return {
      penpal: "call",
      // Actually converting the ID to a number would break communication.
      id: e.id,
      methodName: te(e.methodPath),
      args: e.args
    };
  if (ce(e))
    return e.isError ? {
      penpal: "reply",
      // Actually converting the ID to a number would break communication.
      id: e.callId,
      resolution: "rejected",
      ...e.isSerializedErrorInstance ? {
        returnValue: e.value,
        returnValueIsError: !0
      } : { returnValue: e.value }
    } : {
      penpal: "reply",
      // Actually converting the ID to a number would break communication.
      id: e.callId,
      resolution: "fulfilled",
      returnValue: e.value
    };
  throw fe(e);
}, je = ({
  messenger: e,
  methods: t,
  timeout: r,
  channel: a,
  log: n
}) => {
  const c = ue();
  let d;
  const y = [];
  let u = !1;
  const i = le(t), { promise: o, resolve: w, reject: h } = He(), f = r !== void 0 ? setTimeout(() => {
    h(
      new v(
        "CONNECTION_TIMEOUT",
        `Connection timed out after ${r}ms`
      )
    );
  }, r) : void 0, K = () => {
    for (const l of y)
      l();
  }, x = () => {
    if (u)
      return;
    y.push(Ce(e, t, a, n));
    const { remoteProxy: l, destroy: N } = Oe(e, a, n);
    y.push(N), clearTimeout(f), u = !0, w({
      remoteProxy: l,
      destroy: K
    });
  }, $ = () => {
    const l = {
      namespace: E,
      type: "SYN",
      channel: a,
      participantId: c
    };
    n == null || n("Sending handshake SYN", l);
    try {
      e.sendMessage(l);
    } catch (N) {
      h(new v("TRANSMISSION_FAILED", N.message));
    }
  }, k = (l) => {
    if (n == null || n("Received handshake SYN", l), l.participantId === d && // TODO: Used for backward-compatibility. Remove in next major version.
    d !== W || (d = l.participantId, $(), !(c > d || // TODO: Used for backward-compatibility. Remove in next major version.
    d === W)))
      return;
    const U = {
      namespace: E,
      channel: a,
      type: "ACK1",
      methodPaths: i
    };
    n == null || n("Sending handshake ACK1", U);
    try {
      e.sendMessage(U);
    } catch (pe) {
      h(new v("TRANSMISSION_FAILED", pe.message));
      return;
    }
  }, g = (l) => {
    n == null || n("Received handshake ACK1", l);
    const N = {
      namespace: E,
      channel: a,
      type: "ACK2"
    };
    n == null || n("Sending handshake ACK2", N);
    try {
      e.sendMessage(N);
    } catch (U) {
      h(new v("TRANSMISSION_FAILED", U.message));
      return;
    }
    x();
  }, b = (l) => {
    n == null || n("Received handshake ACK2", l), x();
  }, q = (l) => {
    Y(l) && k(l), X(l) && g(l), z(l) && b(l);
  };
  return e.addMessageHandler(q), y.push(() => e.removeMessageHandler(q)), $(), o;
}, Ve = je, Ke = (e) => {
  let t = !1, r;
  return (...a) => (t || (t = !0, r = e(...a)), r);
}, ge = Ke, re = /* @__PURE__ */ new WeakSet(), ze = ({
  messenger: e,
  methods: t = {},
  timeout: r,
  channel: a,
  log: n
}) => {
  if (!e)
    throw new v("INVALID_ARGUMENT", "messenger must be defined");
  if (re.has(e))
    throw new v(
      "INVALID_ARGUMENT",
      "A messenger can only be used for a single connection"
    );
  re.add(e);
  const c = [e.destroy], d = ge((i) => {
    if (i) {
      const o = {
        namespace: E,
        channel: a,
        type: "DESTROY"
      };
      try {
        e.sendMessage(o);
      } catch {
      }
    }
    for (const o of c)
      o();
    n == null || n("Connection destroyed");
  }), y = (i) => Pe(i) && i.channel === a;
  return {
    promise: (async () => {
      try {
        e.initialize({ log: n, validateReceivedMessage: y }), e.addMessageHandler((w) => {
          Re(w) && d(!1);
        });
        const { remoteProxy: i, destroy: o } = await Ve({
          messenger: e,
          methods: t,
          timeout: r,
          channel: a,
          log: n
        });
        return c.push(o), i;
      } catch (i) {
        throw d(!0), i;
      }
    })(),
    // Why we don't reject the connection promise when consumer calls destroy():
    // https://github.com/Aaronius/penpal/issues/51
    destroy: () => {
      d(!0);
    }
  };
}, We = ze, A, C, P, L, _, R, M, T, j, D, H, F, O, ie, Ge = (ie = class {
  constructor({ remoteWindow: e, allowedOrigins: t }) {
    p(this, A);
    p(this, C);
    p(this, P);
    p(this, L);
    p(this, _);
    p(this, R, /* @__PURE__ */ new Set());
    p(this, M);
    // TODO: Used for backward-compatibility. Remove in next major version.
    p(this, T, !1);
    I(this, "initialize", ({
      log: e,
      validateReceivedMessage: t
    }) => {
      S(this, P, e), S(this, L, t), window.addEventListener("message", s(this, F));
    });
    I(this, "sendMessage", (e, t) => {
      if (Y(e)) {
        const r = s(this, D).call(this, e);
        s(this, A).postMessage(e, {
          targetOrigin: r,
          transfer: t
        });
        return;
      }
      if (X(e) || // If the child is using a previous version of Penpal, we need to
      // downgrade the message and send it through the window rather than
      // the port because older versions of Penpal don't use MessagePorts.
      s(this, T)) {
        const r = s(this, T) ? Ye(e) : e, a = s(this, D).call(this, e);
        s(this, A).postMessage(r, {
          targetOrigin: a,
          transfer: t
        });
        return;
      }
      if (z(e)) {
        const { port1: r, port2: a } = new MessageChannel();
        S(this, M, r), r.addEventListener("message", s(this, O)), r.start();
        const n = [a, ...t || []], c = s(this, D).call(this, e);
        s(this, A).postMessage(e, {
          targetOrigin: c,
          transfer: n
        });
        return;
      }
      if (s(this, M)) {
        s(this, M).postMessage(e, {
          transfer: t
        });
        return;
      }
      throw new v(
        "TRANSMISSION_FAILED",
        "Cannot send message because the MessagePort is not connected"
      );
    });
    I(this, "addMessageHandler", (e) => {
      s(this, R).add(e);
    });
    I(this, "removeMessageHandler", (e) => {
      s(this, R).delete(e);
    });
    I(this, "destroy", () => {
      window.removeEventListener("message", s(this, F)), s(this, H).call(this), s(this, R).clear();
    });
    p(this, j, (e) => s(this, C).some(
      (t) => t instanceof RegExp ? t.test(e) : t === e || t === "*"
    ));
    p(this, D, (e) => {
      if (Y(e))
        return "*";
      if (!s(this, _))
        throw new v(
          "TRANSMISSION_FAILED",
          "Cannot send message because the remote origin is not established"
        );
      return s(this, _) === "null" && s(this, C).includes("*") ? "*" : s(this, _);
    });
    p(this, H, () => {
      var e, t;
      (e = s(this, M)) == null || e.removeEventListener("message", s(this, O)), (t = s(this, M)) == null || t.close(), S(this, M, void 0);
    });
    p(this, F, ({
      source: e,
      origin: t,
      ports: r,
      data: a
    }) => {
      var n, c, d, y, u;
      if (e === s(this, A)) {
        if (Fe(a)) {
          (n = s(this, P)) == null || n.call(
            this,
            "Please upgrade the child window to the latest version of Penpal."
          ), S(this, T, !0);
          try {
            a = Ue(a);
          } catch (i) {
            (c = s(this, P)) == null || c.call(
              this,
              `Failed to translate deprecated message: ${i.message}`
            );
            return;
          }
        }
        if ((d = s(this, L)) != null && d.call(this, a)) {
          if (!s(this, j).call(this, t)) {
            (y = s(this, P)) == null || y.call(
              this,
              `Received a message from origin \`${t}\` which did not match allowed origins \`[${s(this, C).join(", ")}]\``
            );
            return;
          }
          if (Y(a) && (s(this, H).call(this), S(this, _, t)), z(a) && // Previous versions of Penpal don't use MessagePorts and do all
          // communication through the window.
          !s(this, T)) {
            if (S(this, M, r[0]), !s(this, M)) {
              (u = s(this, P)) == null || u.call(this, "Ignoring ACK2 because it did not include a MessagePort");
              return;
            }
            s(this, M).addEventListener("message", s(this, O)), s(this, M).start();
          }
          for (const i of s(this, R))
            i(a);
        }
      }
    });
    p(this, O, ({ data: e }) => {
      var t;
      if ((t = s(this, L)) != null && t.call(this, e))
        for (const r of s(this, R))
          r(e);
    });
    if (!e)
      throw new v("INVALID_ARGUMENT", "remoteWindow must be defined");
    S(this, A, e), S(this, C, t != null && t.length ? t : [window.origin]);
  }
}, A = new WeakMap(), C = new WeakMap(), P = new WeakMap(), L = new WeakMap(), _ = new WeakMap(), R = new WeakMap(), M = new WeakMap(), T = new WeakMap(), j = new WeakMap(), D = new WeakMap(), H = new WeakMap(), F = new WeakMap(), O = new WeakMap(), ie), Je = Ge;
globalThis.__contract__connectToHost = async (e, t) => {
  const r = document.referrer && document.referrer !== "" ? new URL(document.referrer).origin : globalThis.location.origin, a = new Je({
    remoteWindow: globalThis.window.parent,
    allowedOrigins: t ?? [r]
  }), { promise: n, destroy: c } = We({
    messenger: a,
    methods: e
  });
  try {
    const d = await n;
    return {
      status: "connected",
      destroy: c,
      host: d
    };
  } catch (d) {
    return {
      status: "error",
      destroy: c,
      error: d instanceof Error ? d : new Error(String(d))
    };
  }
};
