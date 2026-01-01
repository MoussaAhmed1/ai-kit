---
paths:
  - "**/migrations/**/*.py"
---

# Django Migration Standards

## Safety First

Migrations MUST be:
- Reversible
- Non-destructive
- Tested before deployment

## Dangerous Operations

### Column Removal (3-step process)

```python
# Step 1: Make nullable (Migration 1)
migrations.AlterField(
    model_name='user',
    name='legacy_field',
    field=models.CharField(max_length=100, null=True, blank=True),
)

# Step 2: Deploy code that stops writing to field
# Step 3: Remove field (Migration 2, separate deploy)
migrations.RemoveField(
    model_name='user',
    name='legacy_field',
)
```

### Type Changes

```python
# WRONG - Data loss risk
migrations.AlterField(
    model_name='product',
    name='price',
    field=models.IntegerField(),  # Was DecimalField!
)

# CORRECT - Add new field, migrate data, remove old
migrations.AddField(
    model_name='product',
    name='price_cents',
    field=models.IntegerField(null=True),
)
migrations.RunPython(migrate_price_to_cents, reverse_migrate),
migrations.RemoveField('product', 'price'),
migrations.RenameField('product', 'price_cents', 'price'),
```

## Requirements

- Always include `reverse_code` for RunPython
- Test migrations: forward AND backward
- Never use `--fake` in production
- Review auto-generated migrations before committing

## RunPython Template

```python
def migrate_forward(apps, schema_editor):
    """
    Migration: Convert price to cents.
    """
    Product = apps.get_model('products', 'Product')
    for product in Product.objects.all():
        product.price_cents = int(product.price * 100)
        product.save(update_fields=['price_cents'])


def migrate_backward(apps, schema_editor):
    """
    Reverse: Convert cents back to price.
    """
    Product = apps.get_model('products', 'Product')
    for product in Product.objects.all():
        product.price = product.price_cents / 100
        product.save(update_fields=['price'])


class Migration(migrations.Migration):
    operations = [
        migrations.RunPython(migrate_forward, migrate_backward),
    ]
```

## Forbidden Patterns

- `RunPython(migrate_forward, migrations.RunPython.noop)` - Always provide reverse
- `migrations.DeleteModel` without data backup plan
- Large data migrations without batching
- Migrations that lock tables for long periods

## Large Table Migrations

For tables with >1M rows:

```python
def migrate_in_batches(apps, schema_editor):
    """Migrate data in batches to avoid lock timeouts."""
    Product = apps.get_model('products', 'Product')
    batch_size = 1000
    total = Product.objects.count()

    for start in range(0, total, batch_size):
        batch = Product.objects.all()[start:start + batch_size]
        for product in batch:
            product.new_field = transform(product.old_field)
        Product.objects.bulk_update(batch, ['new_field'])
```

## Migration Naming

Use descriptive names:

```bash
# GOOD
python manage.py makemigrations --name add_email_verified_field
python manage.py makemigrations --name remove_legacy_status_column

# BAD (auto-generated)
0023_auto_20241201_1234.py
```

## Pre-Deployment Checklist

- [ ] Migration is reversible
- [ ] Tested forward migration locally
- [ ] Tested backward migration locally
- [ ] No destructive operations without 3-step process
- [ ] Large tables use batching
- [ ] RunPython has reverse_code
- [ ] Migration name is descriptive
