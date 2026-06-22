import { Controller, Get, Res } from '@nestjs/common';
import type { Response } from 'express';

@Controller('auth')
export class AuthTestController {
  @Get('test')
  serveTestPage(@Res() res: Response) {
    const html = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Shayo — Google Sign-In Test</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      background: #f3f4f6; display: flex; justify-content: center; align-items: center;
      min-height: 100vh;
    }
    .card {
      background: white; border-radius: 12px; padding: 40px; max-width: 480px;
      width: 100%; box-shadow: 0 4px 24px rgba(0,0,0,0.1); text-align: center;
    }
    h1 { font-size: 24px; margin-bottom: 8px; color: #111827; }
    p { color: #6b7280; margin-bottom: 24px; }
    .btn {
      display: inline-flex; align-items: center; gap: 10px; padding: 12px 24px;
      background: #111827; color: white; border: none; border-radius: 8px;
      font-size: 16px; cursor: pointer; text-decoration: none;
    }
    .btn:hover { background: #1f2937; }
    .result {
      margin-top: 24px; text-align: left; background: #f9fafb; border-radius: 8px;
      padding: 16px; font-family: 'Courier New', monospace; font-size: 13px;
      word-break: break-all; white-space: pre-wrap; max-height: 400px; overflow-y: auto;
    }
    .error { color: #dc2626; }
    .hidden { display: none; }
    .spinner {
      display: inline-block; width: 20px; height: 20px; border: 2px solid #e5e7eb;
      border-top-color: #111827; border-radius: 50%; animation: spin .6s linear infinite;
    }
    @keyframes spin { to { transform: rotate(360deg); } }
  </style>
</head>
<body>
  <div class="card">
    <h1>Shayo</h1>
    <p>Test Google Sign-In</p>

    <button class="btn" id="googleBtn">Sign in with Google</button>

    <div id="loading" class="hidden" style="margin-top:24px">
      <div class="spinner"></div>
      <p style="margin-top:8px">Exchanging session...</p>
    </div>

    <pre id="result" class="result hidden"></pre>
    <div id="signedOut" class="hidden" style="margin-top:16px;color:#6b7280">
      Not signed in. Click the button above to sign in with Google.
    </div>
  </div>

  <script>
    document.getElementById('googleBtn').addEventListener('click', async () => {
      const resultEl = document.getElementById('result');
      const btn = document.getElementById('googleBtn');
      btn.disabled = true;
      btn.textContent = 'Redirecting...';

      try {
        const res = await fetch('/sign-in/social', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ provider: 'google', callbackURL: '/auth/test' }),
        });
        const data = await res.json();
        if (data.url) {
          window.location.href = data.url;
        } else {
          resultEl.textContent = JSON.stringify(data, null, 2);
          resultEl.classList.remove('hidden');
          btn.disabled = false;
          btn.textContent = 'Sign in with Google';
        }
      } catch (err) {
        resultEl.textContent = 'Error: ' + err.message;
        resultEl.classList.remove('hidden');
        btn.disabled = false;
        btn.textContent = 'Sign in with Google';
      }
    });

    (async () => {
      const resultEl = document.getElementById('result');
      const loadingEl = document.getElementById('loading');
      const signedOutEl = document.getElementById('signedOut');

      loadingEl.classList.remove('hidden');

      try {
        const res = await fetch('/auth/exchange', { method: 'POST' });
        const data = await res.json();

        loadingEl.classList.add('hidden');

        if (res.ok) {
          resultEl.textContent = JSON.stringify(data, null, 2);
          resultEl.classList.remove('hidden', 'error');
        } else {
          signedOutEl.classList.remove('hidden');
        }
      } catch (err) {
        loadingEl.classList.add('hidden');
        signedOutEl.classList.remove('hidden');
      }
    })();
  </script>
</body>
</html>`;

    res.type('text/html').send(html);
  }
}
