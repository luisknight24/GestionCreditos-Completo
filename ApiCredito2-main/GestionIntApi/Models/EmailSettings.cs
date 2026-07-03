namespace GestionIntApi.Models
{
    public class EmailSettings
    {
        public int Id { get; set; }
        public string From { get; set; }
        public string Password { get; set; }
        public string Host { get; set; }
        public int Port { get; set; }
    }
}
