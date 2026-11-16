package ch.sbb.das.backend.trainjourneypreloader.application;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.Closeable;
import java.io.IOException;
import java.io.UncheckedIOException;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;
import java.util.zip.ZipOutputStream;
import lombok.extern.slf4j.Slf4j;

/** Builds one preload zip in memory, skipping an entry name that was already written. */
@Slf4j
final class ZipWriter implements Closeable {

    private final ByteArrayOutputStream bytes = new ByteArrayOutputStream();
    private final ZipOutputStream zip = new ZipOutputStream(bytes, StandardCharsets.UTF_8);
    private final Set<String> names = new HashSet<>();

    static List<Entry> entriesOf(byte[] zipBytes) throws IOException {
        List<Entry> entries = new ArrayList<>();
        try (ZipInputStream zis = new ZipInputStream(new ByteArrayInputStream(zipBytes), StandardCharsets.UTF_8)) {
            ZipEntry entry;
            while ((entry = zis.getNextEntry()) != null) {
                entries.add(new Entry(entry.getName(), zis.readAllBytes()));
            }
        }
        return entries;
    }

    void transfer(byte[] existingZip) {
        try {
            for (Entry entry : entriesOf(existingZip)) {
                write(entry.name(), entry.content());
            }
        } catch (IOException e) {
            throw new UncheckedIOException("Reading the existing zip failed", e);
        }
    }

    /** The bytes written so far, without the central directory that {@link #finish()} appends. */
    long size() {
        return bytes.size();
    }

    void write(String name, byte[] content) throws IOException {
        if (!names.add(name)) {
            log.warn("Duplicate entry {} in zip skipped", name);
            return;
        }
        zip.putNextEntry(new ZipEntry(name));
        zip.write(content);
        zip.closeEntry();
    }

    byte[] finish() throws IOException {
        zip.close();
        return bytes.toByteArray();
    }

    /** Releases the deflater; closing a finished writer does nothing. */
    @Override
    public void close() {
        try {
            zip.close();
        } catch (IOException e) {
            throw new UncheckedIOException("Closing the zip failed", e);
        }
    }

    /** An entry of a zip with its uncompressed content. */
    static final class Entry {

        private final String name;
        private final byte[] content;

        private Entry(String name, byte[] content) {
            this.name = name;
            this.content = content;
        }

        String name() {
            return name;
        }

        byte[] content() {
            return content;
        }
    }
}
