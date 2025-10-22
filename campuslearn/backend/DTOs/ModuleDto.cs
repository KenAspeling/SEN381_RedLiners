namespace CampusLearnBackend.DTOs
{
    public class ModuleDto
    {
        public int ModuleId { get; set; }
        public string Name { get; set; } = string.Empty;
        public string? Tag { get; set; }
        public string? Description { get; set; }
    }

    public class EnrollModulesDto
    {
        public List<int> ModuleIds { get; set; } = new List<int>();
    }
}
