INSERT INTO ru_indication(id, category, title_de, text_de, title_fr, text_fr, title_it, text_it,
                          companies, operational_train_number_filters, taf_tap_location_references,
                          periods, last_modified_at, last_modified_by)
VALUES (1, 'OPERATIONS',
        'Hinweis 1', 'Text 1 DE', 'Avis 1', 'Texte 1 FR', null, null,
        '1111',
        '[
          {
            "expression": "100-200",
            "parity": "ANY"
          }
        ]',
        'CH00001;CH00002',
        '[
          {
            "validFrom": "2026-01-01",
            "validTo": "2026-12-31",
            "weekdays": []
          }
        ]',
        '2026-01-01 10:00:00', 'unit_test'),
       (2, null,
        'Hinweis 2', 'Text 2 DE', null, null, null, null,
        '1111',
        '[]',
        'CH00002;CH00003',
        '[
          {
            "validFrom": "2026-01-01",
            "validTo": "2026-12-31",
            "weekdays": [
              "MONDAY"
            ]
          }
        ]',
        '2026-01-01 10:00:00', 'unit_test');

