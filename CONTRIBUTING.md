# HRSOFT Development Guidelines

## Code Style

### Python
- Follow PEP 8 standards
- Use type hints for all function parameters and return types
- Maximum line length: 100 characters
- Use meaningful variable and function names

### FastAPI
- Use async/await for all route handlers
- Properly define Pydantic models for request/response
- Include proper HTTP status codes
- Add comprehensive docstrings

### Database
- Use SQLAlchemy ORM
- Always use transactions for multiple operations
- Include proper indexing for frequently queried fields
- Use migrations for schema changes

## Project Structure

### Service Structure
```
service-name/
├── app/
│   ├── __init__.py
│   ├── main.py              # FastAPI app
│   ├── database.py          # Database setup
│   ├── models/              # SQLAlchemy models
│   ├── schemas/             # Pydantic models
│   ├── routers/             # API routes
│   └── services/            # Business logic
├── requirements.txt
└── Dockerfile
```

### Naming Conventions
- **Files**: snake_case (user_service.py)
- **Classes**: PascalCase (UserService)
- **Functions/Variables**: snake_case (get_user_by_id)
- **Constants**: UPPER_SNAKE_CASE (DATABASE_URL)

## Git Workflow

### Branch Naming
- `feature/feature-name` - New features
- `bugfix/issue-description` - Bug fixes
- `hotfix/critical-issue` - Critical fixes
- `refactor/component-name` - Code refactoring

### Commit Messages
```
type(scope): description

Types:
- feat: New feature
- fix: Bug fix
- docs: Documentation
- style: Code style changes
- refactor: Code refactoring
- test: Adding tests
- chore: Maintenance tasks

Examples:
feat(auth): add JWT token refresh endpoint
fix(user): resolve employee email validation
docs(api): update authentication examples
```

## Testing

### Test Structure
```
tests/
├── unit/                    # Unit tests
│   ├── test_auth_service.py
│   └── test_user_service.py
├── integration/             # Integration tests
│   └── test_api_endpoints.py
└── e2e/                     # End-to-end tests
    └── test_user_workflow.py
```

### Test Naming
- Test files: `test_*.py`
- Test functions: `test_function_name`
- Test classes: `TestClassName`

## Security

### Authentication
- Always use HTTPS in production
- JWT tokens should have reasonable expiration times
- Implement proper refresh token rotation
- Store sensitive data in environment variables

### Authorization
- Implement role-based access control (RBAC)
- Validate permissions on every protected endpoint
- Use principle of least privilege

### Data Protection
- Encrypt sensitive data at rest
- Use proper password hashing (bcrypt)
- Validate and sanitize all inputs
- Implement rate limiting

## Performance

### Database
- Use database indexing strategically
- Implement connection pooling
- Use pagination for large datasets
- Optimize N+1 queries with proper joins

### API
- Implement response caching where appropriate
- Use async/await for I/O operations
- Monitor API response times
- Implement proper error handling

## Monitoring

### Logging
- Use structured logging (JSON format)
- Include correlation IDs for request tracing
- Log important business events
- Avoid logging sensitive information

### Health Checks
- Implement health checks for all services
- Monitor database connectivity
- Check external service dependencies
- Include readiness and liveness probes

## Documentation

### API Documentation
- Use OpenAPI/Swagger documentation
- Include examples for all endpoints
- Document error responses
- Keep documentation up to date

### Code Documentation
- Write clear docstrings for all public functions
- Include parameter and return type descriptions
- Document complex business logic
- Maintain up-to-date README files
