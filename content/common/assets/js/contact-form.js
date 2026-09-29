// -----------------------------------------------------------------------------
// CONTACT FORM → FIRESTORE (shared by nasim.pk / nasim.us / nasim.ae)
// -----------------------------------------------------------------------------
//
// Writes the same document shape as the Flutter app's contact form
// (lib/services/contact_service.dart), into the same collection, so every
// surface feeds one inbox:
//
//   name, email, message, source, locale, pageUrl, createdAt
//
// The Firebase config is generated at deploy time by
// .github/workflows/flutter-web.yml from the PUBLIC_FIREBASE_* secrets and
// served as /assets/js/firebase-config.js (window.FIREBASE_CONFIG). Without it
// the form renders disabled with the "unavailable" message — a site built
// without secrets degrades to the email / WhatsApp links instead of pretending
// to send.
//
// The pure helpers (endpoint, buildPayload, validate) are exposed on
// window.NasimContactForm so they can be exercised without a browser.
// -----------------------------------------------------------------------------
(function (global) {
  "use strict";

  var COLLECTION_FALLBACK = "contacts";

  // A bot that fills the honeypot, or submits instantly, gets the success
  // message and no write — it never learns that it was dropped.
  var MIN_FILL_MILLISECONDS = 2000;

  var EMAIL_PATTERN = /^[^@\s]+@[^@\s]+\.[^@\s]{2,}$/;

  function isEmail(value) {
    return EMAIL_PATTERN.test(String(value || "").trim());
  }

  /** Document-create endpoint for the collection, with the API key attached. */
  function endpoint(config, collection) {
    return (
      "https://firestore.googleapis.com/v1/projects/" +
      encodeURIComponent(config.projectId) +
      "/databases/(default)/documents/" +
      encodeURIComponent(collection || COLLECTION_FALLBACK) +
      "?key=" +
      encodeURIComponent(config.apiKey)
    );
  }

  /** Firestore's typed-field representation, identical to the Flutter payload. */
  function buildPayload(values, context) {
    return {
      fields: {
        name: { stringValue: String(values.name || "").trim() },
        email: { stringValue: String(values.email || "").trim() },
        message: { stringValue: String(values.message || "").trim() },
        source: { stringValue: context.source },
        locale: { stringValue: context.locale },
        pageUrl: { stringValue: context.pageUrl },
        createdAt: { stringValue: new Date().toISOString() },
      },
    };
  }

  /**
   * Server-side-independent validation. Returns which field failed first so the
   * caller can focus it.
   */
  function validate(values) {
    var errors = {};

    if (!String(values.name || "").trim()) errors.name = true;
    if (!String(values.email || "").trim() || !isEmail(values.email)) errors.email = true;
    if (!String(values.message || "").trim()) errors.message = true;

    var firstInvalid = null;
    ["name", "email", "message"].some(function (field) {
      if (!errors[field]) return false;
      firstInvalid = field;
      return true;
    });

    return { valid: !firstInvalid, errors: errors, firstInvalid: firstInvalid };
  }

  global.NasimContactForm = {
    endpoint: endpoint,
    buildPayload: buildPayload,
    validate: validate,
    isEmail: isEmail,
    MIN_FILL_MILLISECONDS: MIN_FILL_MILLISECONDS,
    COLLECTION_FALLBACK: COLLECTION_FALLBACK,
  };

  if (typeof document === "undefined") return; // helpers only (e.g. under node)

  function whenReady(callback) {
    if (document.readyState === "loading") {
      document.addEventListener("DOMContentLoaded", callback);
    } else {
      callback();
    }
  }

  whenReady(function () {
    var form = document.getElementById("contact-form");
    if (!form) return;

    var config = global.FIREBASE_CONFIG || {};
    var collection = form.getAttribute("data-collection") || COLLECTION_FALLBACK;
    var status = form.querySelector(".contact-form-status");
    var submitButton = form.querySelector(".contact-form-submit");

    var inputs = {
      name: document.getElementById("contact-name"),
      email: document.getElementById("contact-email"),
      message: document.getElementById("contact-message"),
      company: document.getElementById("contact-company"), // honeypot
    };

    var labels = {
      submit: submitButton.textContent,
      sending: form.getAttribute("data-sending-label") || submitButton.textContent,
      required: form.getAttribute("data-required-message") || "",
      invalidEmail: form.getAttribute("data-invalid-email-message") || "",
      success: form.getAttribute("data-success-message") || "",
      error: form.getAttribute("data-error-message") || "",
      unavailable: form.getAttribute("data-unavailable-message") || "",
    };

    var loadedAt = Date.now();
    var sending = false;

    function setStatus(message, state) {
      if (!status) return;
      status.textContent = message || "";
      if (state) {
        status.setAttribute("data-state", state);
      } else {
        status.removeAttribute("data-state");
      }
    }

    /** Field error spans are named "<input id>-error", e.g. contact-name-error. */
    function showFieldError(field, message) {
      var element = inputs[field];
      var target = document.getElementById(element.id + "-error");

      if (target) target.textContent = message || "";
      if (message) {
        element.setAttribute("aria-invalid", "true");
      } else {
        element.removeAttribute("aria-invalid");
      }
    }

    function clearFieldErrors() {
      Object.keys(inputs).forEach(function (field) {
        showFieldError(field, "");
      });
    }

    function setSending(state) {
      sending = state;
      submitButton.textContent = state ? labels.sending : labels.submit;
      submitButton.setAttribute("aria-busy", state ? "true" : "false");
      submitButton.disabled = state;
    }

    function track(result, detail) {
      if (!Array.isArray(global.dataLayer)) return;
      global.dataLayer.push({
        event: "contact_form_submit",
        result: result,
        detail: String(detail || "").slice(0, 100),
      });
    }

    function succeeded() {
      setSending(false);
      inputs.name.value = "";
      inputs.email.value = "";
      inputs.message.value = "";
      setStatus(labels.success, "success");
    }

    function post(values) {
      var body = JSON.stringify(
        buildPayload(values, {
          source: form.getAttribute("data-source") || "regional-site",
          locale: form.getAttribute("data-locale") || "en",
          pageUrl: global.location ? global.location.href : "",
        })
      );

      var options = {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: body,
      };

      // Same 20s budget as the Flutter app, so a hung request can't leave the
      // button spinning for ever.
      if (typeof AbortController !== "undefined") {
        var controller = new AbortController();
        options.signal = controller.signal;
        global.setTimeout(function () {
          controller.abort();
        }, 20000);
      }

      return global.fetch(endpoint(config, collection), options);
    }

    // Without a usable config the form must not pretend to accept messages.
    if (!config.apiKey || !config.projectId) {
      Object.keys(inputs).forEach(function (field) {
        inputs[field].disabled = true;
      });
      submitButton.disabled = true;
      setStatus(labels.unavailable, "notice");
      return;
    }

    form.addEventListener("submit", function (event) {
      event.preventDefault();
      if (sending) return;

      var values = {
        name: inputs.name.value,
        email: inputs.email.value,
        message: inputs.message.value,
      };

      clearFieldErrors();
      setStatus("", null);

      var result = validate(values);

      if (!result.valid) {
        showFieldError("name", result.errors.name ? labels.required : "");
        showFieldError(
          "email",
          result.errors.email
            ? (String(values.email).trim() ? labels.invalidEmail : labels.required)
            : ""
        );
        showFieldError("message", result.errors.message ? labels.required : "");

        if (result.firstInvalid) inputs[result.firstInvalid].focus();
        return;
      }

      // Bots fill every field — including the hidden one — and never wait.
      if (String(inputs.company.value || "").trim() || Date.now() - loadedAt < MIN_FILL_MILLISECONDS) {
        succeeded();
        return;
      }

      setSending(true);

      post(values)
        .then(function (response) {
          if (response.ok) {
            track("success", "");
            succeeded();
            return null;
          }

          return response.text().then(function (body) {
            track("failure", "HTTP " + response.status + ": " + body);
            setSending(false);
            setStatus(labels.error, "error");
          });
        })
        .catch(function (error) {
          track("failure", String(error));
          setSending(false);
          setStatus(labels.error, "error");
        });
    });

    // Typing again clears the previous outcome, like the Flutter form does.
    Object.keys(inputs).forEach(function (field) {
      inputs[field].addEventListener("input", function () {
        showFieldError(field, "");
        setStatus("", null);
      });
    });
  });

})(typeof window !== "undefined" ? window : globalThis);
