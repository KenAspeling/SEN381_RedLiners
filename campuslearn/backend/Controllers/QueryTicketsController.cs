using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using Microsoft.EntityFrameworkCore;
using CampusLearnBackend.Data;
using CampusLearnBackend.DTOs;
using CampusLearnBackend.Models;
using CampusLearnBackend.Services;

namespace CampusLearnBackend.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class QueryTicketsController : ControllerBase
    {
        private readonly CampusLearnContext _context;
        private readonly IAuthService _authService;

        public QueryTicketsController(CampusLearnContext context, IAuthService authService)
        {
            _context = context;
            _authService = authService;
        }

        // GET: api/querytickets
        [HttpGet]
        public async Task<ActionResult<IEnumerable<QueryTicketDto>>> GetAllTickets()
        {
            var userId = GetCurrentUserId();
            if (userId == null)
                return Unauthorized();

            var accessLevel = await GetAccessLevel(userId.Value);

            List<QueryTicket> tickets;

            if (accessLevel >= AccessLevels.Tutor)
            {
                // Tutors see all tickets
                tickets = await _context.QueryTickets
                    .Include(t => t.User)
                    .Include(t => t.Module)
                    .Include(t => t.StatusType)
                    .Include(t => t.Material)
                    .Include(t => t.Responses)
                        .ThenInclude(r => r.User)
                    .OrderByDescending(t => t.TimeCreated)
                    .ToListAsync();
            }
            else
            {
                // Students see only their own tickets
                tickets = await _context.QueryTickets
                    .Include(t => t.User)
                    .Include(t => t.Module)
                    .Include(t => t.StatusType)
                    .Include(t => t.Material)
                    .Include(t => t.Responses)
                        .ThenInclude(r => r.User)
                    .Where(t => t.UserId == userId.Value)
                    .OrderByDescending(t => t.TimeCreated)
                    .ToListAsync();
            }

            return Ok(tickets.Select(t => MapToDto(t)));
        }

        // GET: api/querytickets/5
        [HttpGet("{id}")]
        public async Task<ActionResult<QueryTicketDto>> GetTicket(int id)
        {
            var userId = GetCurrentUserId();
            if (userId == null)
                return Unauthorized();

            var ticket = await _context.QueryTickets
                .Include(t => t.User)
                .Include(t => t.Module)
                .Include(t => t.StatusType)
                .Include(t => t.Material)
                .Include(t => t.Responses)
                    .ThenInclude(r => r.User)
                .FirstOrDefaultAsync(t => t.TicketId == id);

            if (ticket == null)
                return NotFound();

            // Check if user has permission to view this ticket
            var accessLevel = await GetAccessLevel(userId.Value);
            if (accessLevel < AccessLevels.Tutor && ticket.UserId != userId.Value)
                return Forbid();

            return Ok(MapToDto(ticket));
        }

        // GET: api/querytickets/student/5
        [HttpGet("student/{studentId}")]
        public async Task<ActionResult<IEnumerable<QueryTicketDto>>> GetStudentTickets(int studentId)
        {
            var userId = GetCurrentUserId();
            if (userId == null)
                return Unauthorized();

            // Users can only see their own tickets unless they're a tutor
            var accessLevel = await GetAccessLevel(userId.Value);
            if (accessLevel < AccessLevels.Tutor && userId.Value != studentId)
                return Forbid();

            var tickets = await _context.QueryTickets
                .Include(t => t.User)
                .Include(t => t.Module)
                .Include(t => t.StatusType)
                .Include(t => t.Material)
                .Include(t => t.Responses)
                    .ThenInclude(r => r.User)
                .Where(t => t.UserId == studentId)
                .OrderByDescending(t => t.TimeCreated)
                .ToListAsync();

            return Ok(tickets.Select(t => MapToDto(t)));
        }

        // GET: api/querytickets/open
        [HttpGet("open")]
        public async Task<ActionResult<IEnumerable<QueryTicketDto>>> GetOpenTickets([FromQuery] string? moduleIds)
        {
            var userId = GetCurrentUserId();
            if (userId == null)
                return Unauthorized();

            var accessLevel = await GetAccessLevel(userId.Value);
            if (accessLevel < AccessLevels.Tutor)
                return Forbid();

            var query = _context.QueryTickets
                .Include(t => t.User)
                .Include(t => t.Module)
                .Include(t => t.StatusType)
                .Include(t => t.Material)
                .Include(t => t.Responses)
                    .ThenInclude(r => r.User)
                .Where(t => t.Status == StatusTypes.Sent); // Only sent (open) tickets

            // Filter by modules if provided
            if (!string.IsNullOrEmpty(moduleIds))
            {
                var moduleIdList = moduleIds.Split(',').Select(int.Parse).ToList();
                query = query.Where(t => t.ModuleId.HasValue && moduleIdList.Contains(t.ModuleId.Value));
            }

            var tickets = await query
                .OrderByDescending(t => t.TimeCreated)
                .ToListAsync();

            return Ok(tickets.Select(t => MapToDto(t)));
        }

        // GET: api/querytickets/tutor/5
        [HttpGet("tutor/{tutorId}")]
        public async Task<ActionResult<IEnumerable<QueryTicketDto>>> GetTutorTickets(int tutorId)
        {
            var userId = GetCurrentUserId();
            if (userId == null)
                return Unauthorized();

            var accessLevel = await GetAccessLevel(userId.Value);
            if (accessLevel < AccessLevels.Tutor)
                return Forbid();

            // Only allow tutors to see their own assigned tickets
            if (userId.Value != tutorId)
                return Forbid();

            // Find tickets where this tutor has responded (assigned to them)
            var tickets = await _context.QueryTickets
                .Include(t => t.User)
                .Include(t => t.Module)
                .Include(t => t.StatusType)
                .Include(t => t.Material)
                .Include(t => t.Responses)
                    .ThenInclude(r => r.User)
                .Where(t => t.Responses.Any(r => r.UserId == tutorId))
                .OrderByDescending(t => t.TimeCreated)
                .ToListAsync();

            return Ok(tickets.Select(t => MapToDto(t)));
        }

        // POST: api/querytickets
        [HttpPost]
        public async Task<ActionResult<QueryTicketDto>> CreateTicket([FromBody] CreateQueryTicketDto createDto)
        {
            var userId = GetCurrentUserId();
            if (userId == null)
                return Unauthorized();

            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var ticket = new QueryTicket
            {
                UserId = userId.Value,
                ModuleId = createDto.ModuleId,
                Title = createDto.Title,
                Content = createDto.Content,
                Status = StatusTypes.Sent, // Sent = Open
                TimeCreated = DateTime.UtcNow,
                MaterialId = createDto.MaterialId
            };

            _context.QueryTickets.Add(ticket);
            await _context.SaveChangesAsync();

            // Reload with includes
            ticket = await _context.QueryTickets
                .Include(t => t.User)
                .Include(t => t.Module)
                .Include(t => t.StatusType)
                .Include(t => t.Responses)
                .FirstAsync(t => t.TicketId == ticket.TicketId);

            return CreatedAtAction(nameof(GetTicket), new { id = ticket.TicketId }, MapToDto(ticket));
        }

        // POST: api/querytickets/withfile
        [HttpPost("withfile")]
        [RequestSizeLimit(10 * 1024 * 1024)] // 10 MB limit
        public async Task<ActionResult<QueryTicketDto>> CreateTicketWithFile(
            [FromForm] string title,
            [FromForm] string content,
            [FromForm] int moduleId,
            [FromForm] IFormFile? file)
        {
            var userId = GetCurrentUserId();
            if (userId == null)
                return Unauthorized();

            // Validate input
            if (string.IsNullOrWhiteSpace(title) || title.Length > 200)
                return BadRequest("Title is required and must be at most 200 characters");

            if (string.IsNullOrWhiteSpace(content))
                return BadRequest("Content is required");

            int? materialId = null;

            // Handle file upload if provided
            if (file != null && file.Length > 0)
            {
                try
                {
                    const long MaxFileSize = 10 * 1024 * 1024; // 10 MB
                    var allowedExtensions = new[] { ".pdf", ".doc", ".docx", ".txt", ".jpg", ".jpeg", ".png" };

                    if (file.Length > MaxFileSize)
                        return BadRequest($"File size exceeds maximum allowed size of {MaxFileSize / (1024 * 1024)} MB");

                    var extension = Path.GetExtension(file.FileName).ToLowerInvariant();
                    if (!allowedExtensions.Contains(extension))
                        return BadRequest($"File type not allowed. Allowed types: {string.Join(", ", allowedExtensions)}");

                    // Read file data
                    byte[] fileData;
                    using (var memoryStream = new MemoryStream())
                    {
                        await file.CopyToAsync(memoryStream);
                        fileData = memoryStream.ToArray();
                    }

                    // Create material record
                    var material = new Material
                    {
                        Title = file.FileName,
                        FileName = file.FileName,
                        FileType = file.ContentType,
                        FileSize = file.Length,
                        FileData = fileData,
                        TimeCreated = DateTime.UtcNow
                    };

                    _context.Materials.Add(material);
                    await _context.SaveChangesAsync();

                    materialId = material.MaterialId;

                    Console.WriteLine($"[TICKET] File uploaded: {file.FileName} ({file.Length} bytes) - Material ID: {material.MaterialId}");
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Error uploading file: {ex.Message}");
                    return StatusCode(500, $"Error uploading file: {ex.Message}");
                }
            }

            var ticket = new QueryTicket
            {
                UserId = userId.Value,
                ModuleId = moduleId,
                Title = title,
                Content = content,
                Status = StatusTypes.Sent, // Sent = Open
                TimeCreated = DateTime.UtcNow,
                MaterialId = materialId
            };

            _context.QueryTickets.Add(ticket);
            await _context.SaveChangesAsync();

            // Reload with includes
            ticket = await _context.QueryTickets
                .Include(t => t.User)
                .Include(t => t.Module)
                .Include(t => t.StatusType)
                .Include(t => t.Responses)
                .Include(t => t.Material)
                .FirstAsync(t => t.TicketId == ticket.TicketId);

            return CreatedAtAction(nameof(GetTicket), new { id = ticket.TicketId }, MapToDto(ticket));
        }

        // PUT: api/querytickets/5/claim
        [HttpPut("{id}/claim")]
        public async Task<ActionResult<QueryTicketDto>> ClaimTicket(int id)
        {
            var userId = GetCurrentUserId();
            if (userId == null)
                return Unauthorized();

            var accessLevel = await GetAccessLevel(userId.Value);
            if (accessLevel < AccessLevels.Tutor)
                return Forbid();

            var ticket = await _context.QueryTickets
                .Include(t => t.User)
                .Include(t => t.Module)
                .Include(t => t.StatusType)
                .Include(t => t.Material)
                .Include(t => t.Responses)
                    .ThenInclude(r => r.User)
                .FirstOrDefaultAsync(t => t.TicketId == id);

            if (ticket == null)
                return NotFound();

            if (ticket.Status != StatusTypes.Sent)
                return BadRequest("Ticket is not available to claim");

            // Update status to Received (In Progress)
            ticket.Status = StatusTypes.Received;

            // Create an initial response to mark tutor assignment
            var response = new Response
            {
                QueryId = ticket.TicketId,
                UserId = userId.Value,
                Content = "[CLAIMED]", // Marker to indicate claimed
                TimeCreated = DateTime.UtcNow
            };

            _context.Responses.Add(response);
            await _context.SaveChangesAsync();

            // Reload with includes
            ticket = await _context.QueryTickets
                .Include(t => t.User)
                .Include(t => t.Module)
                .Include(t => t.StatusType)
                .Include(t => t.Responses)
                    .ThenInclude(r => r.User)
                .FirstAsync(t => t.TicketId == id);

            return Ok(MapToDto(ticket));
        }

        // POST: api/querytickets/5/respond
        [HttpPost("{id}/respond")]
        public async Task<ActionResult<QueryTicketDto>> RespondToTicket(int id, [FromBody] RespondToQueryTicketDto respondDto)
        {
            var userId = GetCurrentUserId();
            if (userId == null)
                return Unauthorized();

            var accessLevel = await GetAccessLevel(userId.Value);
            if (accessLevel < AccessLevels.Tutor)
                return Forbid();

            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var ticket = await _context.QueryTickets
                .Include(t => t.User)
                .Include(t => t.Module)
                .Include(t => t.StatusType)
                .Include(t => t.Material)
                .Include(t => t.Responses)
                    .ThenInclude(r => r.User)
                .FirstOrDefaultAsync(t => t.TicketId == id);

            if (ticket == null)
                return NotFound();

            // Check if this tutor has claimed the ticket
            var hasClaimed = ticket.Responses.Any(r => r.UserId == userId.Value);
            if (!hasClaimed)
                return BadRequest("You must claim this ticket before responding");

            // Update status to Responded
            ticket.Status = StatusTypes.Responded;

            // Create the actual response
            var response = new Response
            {
                QueryId = ticket.TicketId,
                UserId = userId.Value,
                Content = respondDto.Content,
                TimeCreated = DateTime.UtcNow,
                MaterialId = respondDto.MaterialId
            };

            _context.Responses.Add(response);
            await _context.SaveChangesAsync();

            // Reload with includes
            ticket = await _context.QueryTickets
                .Include(t => t.User)
                .Include(t => t.Module)
                .Include(t => t.StatusType)
                .Include(t => t.Responses)
                    .ThenInclude(r => r.User)
                .FirstAsync(t => t.TicketId == id);

            return Ok(MapToDto(ticket));
        }

        // Helper methods
        private int? GetCurrentUserId()
        {
            var authHeader = Request.Headers["Authorization"].FirstOrDefault();
            if (authHeader == null || !authHeader.StartsWith("Bearer "))
                return null;

            var token = authHeader.Substring("Bearer ".Length).Trim();
            return _authService.GetUserIdFromToken(token);
        }

        private async Task<int> GetAccessLevel(int userId)
        {
            var accessLevel = await _authService.GetAccessLevelAsync(userId);
            return accessLevel ?? AccessLevels.Student;
        }

        private QueryTicketDto MapToDto(QueryTicket ticket)
        {
            var dto = new QueryTicketDto
            {
                TicketId = ticket.TicketId,
                UserId = ticket.UserId ?? 0,
                UserName = ticket.User != null ? $"{ticket.User.Name} {ticket.User.Surname}" : "Unknown",
                UserEmail = ticket.User?.Email ?? "unknown@email.com",
                ModuleId = ticket.ModuleId ?? 0,
                ModuleName = ticket.Module?.Name ?? "Unknown Module",
                Title = ticket.Title,
                Content = ticket.Content,
                Status = ticket.Status ?? StatusTypes.Sent,
                StatusName = ticket.StatusType?.Name ?? "Sent",
                TimeCreated = ticket.TimeCreated,
                MaterialId = ticket.MaterialId,
                FileName = ticket.Material?.FileName,
                FileType = ticket.Material?.FileType,
                FileSize = ticket.Material?.FileSize
            };

            // Get the latest response (that's not a claim marker)
            var response = ticket.Responses
                .Where(r => r.Content != "[CLAIMED]")
                .OrderByDescending(r => r.TimeCreated)
                .FirstOrDefault();

            if (response != null)
            {
                dto.ResponseId = response.ResponseId;
                dto.ResponseContent = response.Content;
                dto.TutorId = response.UserId;
                dto.TutorName = response.User != null ? $"{response.User.Name} {response.User.Surname}" : "Unknown Tutor";
                dto.TutorEmail = response.User?.Email ?? "unknown@email.com";
                dto.TimeResponded = response.TimeCreated;
            }
            else
            {
                // Check if there's a claim marker to get tutor info
                var claimResponse = ticket.Responses
                    .OrderByDescending(r => r.TimeCreated)
                    .FirstOrDefault();

                if (claimResponse != null)
                {
                    dto.TutorId = claimResponse.UserId;
                    dto.TutorName = claimResponse.User != null ? $"{claimResponse.User.Name} {claimResponse.User.Surname}" : "Unknown Tutor";
                    dto.TutorEmail = claimResponse.User?.Email ?? "unknown@email.com";
                }
            }

            return dto;
        }
    }

    // Access level constants (should match User model)
    public static class AccessLevels
    {
        public const int Student = 1;
        public const int Tutor = 2;
        public const int Admin = 3;
    }
}
