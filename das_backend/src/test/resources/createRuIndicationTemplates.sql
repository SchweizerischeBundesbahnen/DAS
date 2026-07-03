INSERT INTO ru_indication_template(id, category, title_de, text_de, title_fr, text_fr, title_it,
                                   text_it, tenant, last_modified_at, last_modified_by)
VALUES (1, 'OPERATIONS', 'Standardtext 1', 'Text 1 DE', 'Avis 1', 'Texte 1 FR', 'Avviso 1',
        'Testo 1 IT', 'sbb', '2025-04-17 10:18:34', 'unit_test'),
       (2, 'SAFETY', 'Standardtext 2', 'Text 2 DE', 'Avis 2', 'Texte 2 FR', 'Avviso 2',
        'Testo 2 IT', 'sbb', '2025-04-18 11:20:00', 'unit_test'),
       (3, 'INFO', 'Standardtext 3', 'Text 3 DE', 'Avis 3', 'Texte 3 FR', 'Avviso 3', 'Testo 3 IT',
        'sbb', '2025-04-19 12:21:00', 'unit_test'),
       (4, 'OPERATIONS', 'Standardtext 4', 'Text 4 DE', 'Avis 4', 'Texte 4 FR', 'Avviso 4',
        'Testo 4 IT', 'unknown-tenant', '2025-04-20 13:22:00', 'unit_test');

