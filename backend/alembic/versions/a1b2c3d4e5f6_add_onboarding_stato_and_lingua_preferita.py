"""Aggiunge onboarding_stato e lingua_preferita a utenti

Revision ID: a1b2c3d4e5f6
Revises: 716b95629203
Create Date: 2026-04-08 22:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision: str = 'a1b2c3d4e5f6'
down_revision: Union[str, None] = '716b95629203'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None

# Enum PostgreSQL per lo stato dell'onboarding
onboarding_stato_enum = sa.Enum(
    'not_started', 'in_progress', 'completed',
    name='onboarding_stato_enum',
)


def upgrade() -> None:
    # Crea il tipo enum PostgreSQL
    onboarding_stato_enum.create(op.get_bind(), checkfirst=True)

    # Aggiungi colonna onboarding_stato con default 'not_started'
    op.add_column(
        'utenti',
        sa.Column(
            'onboarding_stato',
            onboarding_stato_enum,
            nullable=False,
            server_default='not_started',
        ),
    )

    # Aggiungi colonna lingua_preferita con default 'it'
    op.add_column(
        'utenti',
        sa.Column(
            'lingua_preferita',
            sa.String(length=10),
            nullable=False,
            server_default='it',
        ),
    )


def downgrade() -> None:
    op.drop_column('utenti', 'lingua_preferita')
    op.drop_column('utenti', 'onboarding_stato')

    # Rimuovi il tipo enum PostgreSQL
    onboarding_stato_enum.drop(op.get_bind(), checkfirst=True)
