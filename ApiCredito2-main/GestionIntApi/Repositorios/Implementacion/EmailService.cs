using GestionIntApi.Models;
using GestionIntApi.Repositorios.Interfaces;
using Microsoft.Extensions.Options;
using SendGrid;
using SendGrid.Helpers.Mail;
using System.Net;
using System.Net.Http;
using System.Net.Mail;
using System.Text;
using System.Text.Json; 



namespace GestionIntApi.Repositorios.Implementacion
{
    public class EmailService : IEmailService
    {

        private readonly EmailSettings _settings;
        private readonly SendGridSettings _settings1;
        private readonly HttpClient _httpClient;
        /*public EmailService(IOptions<SendGridSettings> options)
        {
            _settings1 = options.Value
                ?? throw new ArgumentNullException(nameof(options));
        }
        */


        // public EmailService(IOptions<SendGridSettings> settings)
        // {
        //  _settings = settings.Value;
        //}
        /*
        public async Task SendEmailAsync(string to, string subject, string body)
        {
            var message = new MailMessage();
            message.From = new MailAddress(_settings.From);
            message.To.Add(to);
            message.Subject = subject;
            message.Body = body;
            message.IsBodyHtml = true;

            var smtp = new SmtpClient(_settings.Host)
            {
                Port = _settings.Port,
                Credentials = new NetworkCredential(_settings.From, _settings.Password),
                EnableSsl = true
            };

            await smtp.SendMailAsync(message);
        }
        */


        public async Task SendEmailAsync1(string to, string subject, string body)
        {
            var client = new SendGridClient(_settings1.ApiKey);
            var from = new EmailAddress(_settings1.FromEmail, _settings1.FromName);
            var toEmail = new EmailAddress(to);
            var msg = MailHelper.CreateSingleEmail(from, toEmail, subject, body, body);

            var response = await client.SendEmailAsync(msg);
            if ((int)response.StatusCode >= 200 && (int)response.StatusCode < 300)
                Console.WriteLine("Correo enviado correctamente.");
            else
                Console.WriteLine($"Error al enviar correo: {response.StatusCode}");
        }


        public async Task SendEmailAsync2coorectoantes(string to, string subject, string body)
        {
            if (string.IsNullOrWhiteSpace(_settings1.ApiKey))
                throw new Exception("SendGrid ApiKey no configurada");

            var client = new SendGridClient(_settings1.ApiKey);

            var from = new EmailAddress(_settings1.FromEmail, _settings1.FromName);
            var toEmail = new EmailAddress(to);

            var msg = MailHelper.CreateSingleEmail(
                from,
                toEmail,
                subject,
                body,
                body
            );

            await client.SendEmailAsync(msg);
        }


        public EmailService(IOptions<SendGridSettings> options, IHttpClientFactory httpClientFactory)
        {

          
            _settings1 = options.Value
                ?? throw new ArgumentNullException(nameof(options));


            // Inicializar HttpClient
            _httpClient = httpClientFactory.CreateClient(); // ← Agregar esta línea

            // Sobrescribimos ApiKey con la variable de entorno si existe
            var apiKeyFromEnv = Environment.GetEnvironmentVariable("SENDGRID_API_KEY");
            if (!string.IsNullOrWhiteSpace(apiKeyFromEnv))
                _settings1.ApiKey = apiKeyFromEnv;
        }

        public async Task SendEmailAsyncantesdebrevo(string to, string subject, string body)
        {
            Console.WriteLine("📧 [SENDGRID] Iniciando envío de correo...");
            Console.WriteLine($"📨 [SENDGRID] Destinatario: {to}");
            Console.WriteLine($"📝 [SENDGRID] Asunto: {subject}");

            if (string.IsNullOrWhiteSpace(_settings1.ApiKey))
            {
                Console.WriteLine("❌ [SENDGRID] ApiKey está VACÍA o NULL");
                throw new Exception("SendGrid ApiKey no configurada");
            }

            Console.WriteLine($"🔑 [SENDGRID] ApiKey detectada (length: {_settings1.ApiKey.Length})");
            Console.WriteLine($"👤 [SENDGRID] FromEmail: {_settings1.FromEmail}");
            Console.WriteLine($"🏷️ [SENDGRID] FromName: {_settings1.FromName}");

            var client = new SendGridClient(_settings1.ApiKey);
            var from = new EmailAddress(_settings1.FromEmail, _settings1.FromName);
            var toEmail = new EmailAddress(to);

            var msg = MailHelper.CreateSingleEmail(
                from,
                toEmail,
                subject,
                body,
                body
            );

            Console.WriteLine("🚀 [SENDGRID] Enviando correo a SendGrid...");

            var response = await client.SendEmailAsync(msg);



            Console.WriteLine($"📡 [SENDGRID] StatusCode: {(int)response.StatusCode}");

            if ((int)response.StatusCode >= 200 && (int)response.StatusCode < 300)
            {
                Console.WriteLine("✅ [SENDGRID] Correo enviado correctamente.");
            }
            else
            {
                var responseBody = await response.Body.ReadAsStringAsync();
                Console.WriteLine("❌ [SENDGRID] Error al enviar correo");
                Console.WriteLine($"📄 [SENDGRID] Response body: {responseBody}");
            }
        }


        public async Task SendEmailAsync(string to, string subject, string body)
        {
            var gmailPassword = Environment.GetEnvironmentVariable("EmailSettings__Password");
            var apiKeyFromEnv = Environment.GetEnvironmentVariable("SENDGRID_API_KEY") ?? _settings1.ApiKey;

            // 1. Intentar con Brevo / SendGrid si la API Key está configurada
            if (!string.IsNullOrWhiteSpace(apiKeyFromEnv) && apiKeyFromEnv != "PON_TU_API_KEY_AQUI")
            {
                try
                {
                    var emailData = new
                    {
                        sender = new { name = _settings1.FromName ?? "Gestión Créditos", email = _settings1.FromEmail ?? "luisknight24@gmail.com" },
                        to = new[] { new { email = to } },
                        subject = subject,
                        htmlContent = body
                    };

                    var jsonPayload = JsonSerializer.Serialize(emailData);
                    var content = new StringContent(jsonPayload, Encoding.UTF8, "application/json");

                    var request = new HttpRequestMessage(HttpMethod.Post, "https://api.brevo.com/v3/smtp/email");
                    request.Headers.Add("api-key", apiKeyFromEnv);
                    request.Content = content;

                    var response = await _httpClient.SendAsync(request);
                    if (response.IsSuccessStatusCode)
                    {
                        Console.WriteLine("✅ [BREVO] Correo enviado correctamente.");
                        return;
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"⚠️ [BREVO] Excepción: {ex.Message}");
                }
            }

            // 2. Intentar con Gmail SMTP si EmailSettings__Password está configurada
            if (!string.IsNullOrWhiteSpace(gmailPassword))
            {
                try
                {
                    Console.WriteLine("📧 [GMAIL SMTP] Enviando correo vía Gmail SMTP...");
                    using (var message = new MailMessage())
                    {
                        message.From = new MailAddress("luisknight24@gmail.com", "Gestión Créditos");
                        message.To.Add(to);
                        message.Subject = subject;
                        message.Body = body;
                        message.IsBodyHtml = true;

                        using (var smtp = new SmtpClient("smtp.gmail.com", 587))
                        {
                            smtp.Credentials = new NetworkCredential("luisknight24@gmail.com", gmailPassword);
                            smtp.EnableSsl = true;
                            await smtp.SendMailAsync(message);
                        }
                    }
                    Console.WriteLine("✅ [GMAIL SMTP] Correo enviado vía Gmail SMTP correctamente.");
                    return;
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"❌ [GMAIL SMTP] Error enviando correo: {ex.Message}");
                }
            }

            Console.WriteLine("⚠️ [EMAIL] Sin credenciales activas (Brevo/Gmail). Saltando envío real.");
            Console.WriteLine($"🔑 [DEV ONLY] Contenido del correo: {body}");
        }

    }
}
