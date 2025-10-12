#!/bin/bash
# Smicolon Post-Write Hook
# This hook validates files after Claude writes them to ensure Smicolon conventions

# Get the file path from the first argument
FILE_PATH="$1"

# Only check Python files in Django projects
if [[ "$FILE_PATH" == *.py ]] && [ -f "manage.py" ]; then
  echo "🔍 Validating Smicolon conventions in $FILE_PATH..."

  VIOLATIONS=""

  # Check for relative imports
  if grep -n "^from \." "$FILE_PATH" 2>/dev/null | head -5; then
    VIOLATIONS="${VIOLATIONS}
❌ RELATIVE IMPORTS DETECTED
Smicolon Standard: Use absolute modular imports with aliases
Found in: $FILE_PATH
Fix: Use 'import users.models as _models' instead of 'from .models import X'
"
  fi

  # Check for non-modular imports (direct class imports from app modules)
  if grep -n "^from \(users\|core\|products\|orders\|features\..*\)\.\(models\|services\|serializers\|views\) import" "$FILE_PATH" 2>/dev/null | head -3; then
    VIOLATIONS="${VIOLATIONS}
⚠️  DIRECT CLASS IMPORTS DETECTED
Smicolon Standard: Use modular imports with aliases
Found in: $FILE_PATH
App-based: import users.models as _models
Feature-based: import features.authentication.models as _auth_models
Instead of: from users.models import User
"
  fi

  # Check if it's a models.py file and has proper UUID/timestamps
  if [[ "$FILE_PATH" == */models.py ]] || [[ "$FILE_PATH" == */models/*.py ]]; then
    # Check for models without UUID primary key
    if grep -q "class.*Model)" "$FILE_PATH" 2>/dev/null; then
      if ! grep -q "UUIDField.*primary_key" "$FILE_PATH" 2>/dev/null; then
        VIOLATIONS="${VIOLATIONS}
⚠️  MODEL WITHOUT UUID PRIMARY KEY
Smicolon Standard: All models must use UUID primary keys
File: $FILE_PATH
Required: id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
"
      fi

      # Check for timestamps
      if ! grep -q "created_at.*DateTimeField" "$FILE_PATH" 2>/dev/null; then
        VIOLATIONS="${VIOLATIONS}
⚠️  MODEL WITHOUT TIMESTAMPS
Smicolon Standard: All models must have created_at and updated_at
File: $FILE_PATH
Required: created_at = models.DateTimeField(auto_now_add=True)
          updated_at = models.DateTimeField(auto_now=True)
"
      fi

      # Check for soft delete
      if ! grep -q "is_deleted.*BooleanField" "$FILE_PATH" 2>/dev/null; then
        VIOLATIONS="${VIOLATIONS}
⚠️  MODEL WITHOUT SOFT DELETE
Smicolon Standard: All models must have is_deleted field
File: $FILE_PATH
Required: is_deleted = models.BooleanField(default=False)
"
      fi
    fi
  fi

  # Check if it's a views.py file and has permission classes
  if [[ "$FILE_PATH" == */views.py ]] || [[ "$FILE_PATH" == */views/*.py ]]; then
    if grep -q "ViewSet\|APIView" "$FILE_PATH" 2>/dev/null; then
      if ! grep -q "permission_classes" "$FILE_PATH" 2>/dev/null; then
        VIOLATIONS="${VIOLATIONS}
⚠️  VIEW WITHOUT PERMISSION CLASSES
Smicolon Standard: All views must define permission_classes
File: $FILE_PATH
Required: permission_classes = [IsAuthenticated] or appropriate permissions
"
      fi
    fi
  fi

  # If violations found, notify user
  if [ -n "$VIOLATIONS" ]; then
    echo "
┌────────────────────────────────────────────┐
│  ⚠️  SMICOLON CONVENTION VIOLATIONS        │
└────────────────────────────────────────────┘
$VIOLATIONS
💡 Please fix these violations to comply with Smicolon standards.
📖 Run /django-review for a full security and convention review.
"
  else
    echo "✅ File follows Smicolon conventions"
  fi
fi

# Check TypeScript files in Next.js projects
if [[ "$FILE_PATH" == *.tsx ]] || [[ "$FILE_PATH" == *.ts ]] && [ -f "package.json" ] && grep -q "next" package.json 2>/dev/null; then
  echo "🔍 Validating Smicolon Next.js conventions in $FILE_PATH..."

  VIOLATIONS=""

  # Check for 'any' type usage
  if grep -n ": any" "$FILE_PATH" 2>/dev/null | head -3; then
    VIOLATIONS="${VIOLATIONS}
⚠️  'any' TYPE DETECTED
Smicolon Standard: Avoid 'any' types, use proper type definitions
File: $FILE_PATH
"
  fi

  # Check for forms without validation
  if grep -q "useForm" "$FILE_PATH" 2>/dev/null; then
    if ! grep -q "zodResolver\|yupResolver" "$FILE_PATH" 2>/dev/null; then
      VIOLATIONS="${VIOLATIONS}
⚠️  FORM WITHOUT VALIDATION SCHEMA
Smicolon Standard: All forms must use Zod validation
File: $FILE_PATH
Required: zodResolver(yourSchema) in useForm options
"
    fi
  fi

  if [ -n "$VIOLATIONS" ]; then
    echo "
┌────────────────────────────────────────────┐
│  ⚠️  SMICOLON CONVENTION VIOLATIONS        │
└────────────────────────────────────────────┘
$VIOLATIONS
💡 Please fix these violations to comply with Smicolon standards.
"
  else
    echo "✅ File follows Smicolon conventions"
  fi
fi

# Check Vue/Nuxt files
if [[ "$FILE_PATH" == *.vue ]] && [ -f "package.json" ] && grep -q "nuxt" package.json 2>/dev/null; then
  echo "🔍 Validating Smicolon Nuxt.js conventions in $FILE_PATH..."

  VIOLATIONS=""

  # Check for Composition API usage
  if grep -q "<script" "$FILE_PATH" 2>/dev/null; then
    if ! grep -q "<script setup" "$FILE_PATH" 2>/dev/null; then
      VIOLATIONS="${VIOLATIONS}
⚠️  NOT USING COMPOSITION API
Smicolon Standard: Always use <script setup lang=\"ts\">
File: $FILE_PATH
Required: <script setup lang=\"ts\"> for all components
"
    fi
  fi

  # Check for TypeScript
  if grep -q "<script setup>" "$FILE_PATH" 2>/dev/null; then
    if ! grep -q "lang=\"ts\"" "$FILE_PATH" 2>/dev/null; then
      VIOLATIONS="${VIOLATIONS}
⚠️  MISSING TYPESCRIPT
Smicolon Standard: All components must use TypeScript
File: $FILE_PATH
Required: <script setup lang=\"ts\">
"
    fi
  fi

  # Check for 'any' type in script
  if grep -n ": any" "$FILE_PATH" 2>/dev/null | head -3; then
    VIOLATIONS="${VIOLATIONS}
⚠️  'any' TYPE DETECTED
Smicolon Standard: Avoid 'any' types, use proper type definitions
File: $FILE_PATH
"
  fi

  if [ -n "$VIOLATIONS" ]; then
    echo "
┌────────────────────────────────────────────┐
│  ⚠️  SMICOLON CONVENTION VIOLATIONS        │
└────────────────────────────────────────────┘
$VIOLATIONS
💡 Please fix these violations to comply with Smicolon standards.
"
  else
    echo "✅ File follows Smicolon conventions"
  fi
fi

# Check TypeScript files in NestJS projects
if [[ "$FILE_PATH" == *.ts ]] && [ -f "package.json" ] && grep -q "@nestjs/core" package.json 2>/dev/null; then
  echo "🔍 Validating Smicolon NestJS conventions in $FILE_PATH..."

  VIOLATIONS=""

  # Check for relative imports
  if grep -n "^import.*from '\\.\\/" "$FILE_PATH" 2>/dev/null | head -3; then
    VIOLATIONS="${VIOLATIONS}
❌ RELATIVE IMPORTS DETECTED
Smicolon Standard: Use absolute imports from barrel exports
Found in: $FILE_PATH
Fix: Use 'import { User } from \"src/users/entities\"' instead of './entities/user.entity'
"
  fi

  # Check for entities without UUID primary key
  if grep -q "@Entity" "$FILE_PATH" 2>/dev/null; then
    if ! grep -q "@PrimaryGeneratedColumn('uuid')" "$FILE_PATH" 2>/dev/null; then
      VIOLATIONS="${VIOLATIONS}
⚠️  ENTITY WITHOUT UUID PRIMARY KEY
Smicolon Standard: All entities must use UUID primary keys
File: $FILE_PATH
Required: @PrimaryGeneratedColumn('uuid')
"
    fi

    if ! grep -q "@CreateDateColumn()" "$FILE_PATH" 2>/dev/null; then
      VIOLATIONS="${VIOLATIONS}
⚠️  ENTITY WITHOUT TIMESTAMPS
Smicolon Standard: All entities must have timestamps
File: $FILE_PATH
Required: @CreateDateColumn() and @UpdateDateColumn()
"
    fi

    if ! grep -q "@DeleteDateColumn()" "$FILE_PATH" 2>/dev/null; then
      VIOLATIONS="${VIOLATIONS}
⚠️  ENTITY WITHOUT SOFT DELETE
Smicolon Standard: All entities must have soft delete
File: $FILE_PATH
Required: @DeleteDateColumn()
"
    fi
  fi

  if [ -n "$VIOLATIONS" ]; then
    echo "
┌────────────────────────────────────────────┐
│  ⚠️  SMICOLON CONVENTION VIOLATIONS        │
└────────────────────────────────────────────┘
$VIOLATIONS
💡 Please fix these violations to comply with Smicolon standards.
"
  else
    echo "✅ File follows Smicolon conventions"
  fi
fi

# Always allow the write to proceed
exit 0
