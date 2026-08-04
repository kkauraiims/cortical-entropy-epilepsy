DROP TABLE IF EXISTS se_data_clean;

CREATE TABLE se_data_clean AS
SELECT
    ROW_NUMBER() OVER (ORDER BY rowid) AS hour,

    CASE
        WHEN TRIM(SampleEntropyMatrix1) IN ('', 'NA', 'NaN') THEN NULL
        ELSE CAST(SampleEntropyMatrix1 AS REAL)
    END AS cont1,

    CASE
        WHEN TRIM(SampleEntropyMatrix2) IN ('', 'NA', 'NaN') THEN NULL
        ELSE CAST(SampleEntropyMatrix2 AS REAL)
    END AS cont2,

    CASE
        WHEN TRIM(SampleEntropyMatrix3) IN ('', 'NA', 'NaN') THEN NULL
        ELSE CAST(SampleEntropyMatrix3 AS REAL)
    END AS cont3,

    CASE
        WHEN TRIM(SampleEntropyMatrix4) IN ('', 'NA', 'NaN') THEN NULL
        ELSE CAST(SampleEntropyMatrix4 AS REAL)
    END AS cont4,

    CASE
        WHEN TRIM(SampleEntropyMatrix5) IN ('', 'NA', 'NaN') THEN NULL
        ELSE CAST(SampleEntropyMatrix5 AS REAL)
    END AS cont5,

    CASE
        WHEN TRIM(SampleEntropyMatrix6) IN ('', 'NA', 'NaN') THEN NULL
        ELSE CAST(SampleEntropyMatrix6 AS REAL)
    END AS lg1,

    CASE
        WHEN TRIM(SampleEntropyMatrix7) IN ('', 'NA', 'NaN') THEN NULL
        ELSE CAST(SampleEntropyMatrix7 AS REAL)
    END AS lg2,

    CASE
        WHEN TRIM(SampleEntropyMatrix8) IN ('', 'NA', 'NaN') THEN NULL
        ELSE CAST(SampleEntropyMatrix8 AS REAL)
    END AS lg3,

    CASE
        WHEN TRIM(SampleEntropyMatrix9) IN ('', 'NA', 'NaN') THEN NULL
        ELSE CAST(SampleEntropyMatrix9 AS REAL)
    END AS lg4,

    CASE
        WHEN TRIM(SampleEntropyMatrix10) IN ('', 'NA', 'NaN') THEN NULL
        ELSE CAST(SampleEntropyMatrix10 AS REAL)
    END AS lg5

FROM se_data;
