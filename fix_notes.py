import re

with open("luxury/Core/SalesAssociate/Clienteling/Services/NotesService.swift", "r") as f:
    content = f.read()

# Replace syncNotes do block
sync_block = """        do {
            let dbNotes: [DBClientNote] = try await client
                .from("client_notes")
                .select()
                .eq("client_id", value: clientId.uuidString)
                .execute()
                .value
            
            let notes = dbNotes.map {
                ClientNote(id: $0.id, note: $0.note, date: $0.date, author: $0.author)
            }
            saveLocalNotes(notes, for: clientId)
        } catch {
            print("Supabase fetch client_notes warning: \\(error.localizedDescription)")
        }"""
        
sync_replacement = """        // Supabase table 'client_notes' does not exist in schema yet.
        // Relying on local notes only.
        // do {
        //     let dbNotes: [DBClientNote] = try await client
        //         .from("client_notes")
        //         ...
        // }"""

content = content.replace(sync_block, sync_replacement)

# Replace addNote do block
add_block = """        // Sync to Supabase in background
        do {
            let dbNote = DBClientNote(
                id: newNote.id,
                clientId: clientId,
                note: newNote.note,
                date: newNote.date,
                author: newNote.author
            )
            try await client
                .from("client_notes")
                .insert(dbNote)
                .execute()
        } catch {
            print("Supabase notes sync warning: \\(error.localizedDescription)")
        }"""

add_replacement = """        // Sync to Supabase disabled (table 'client_notes' not in schema)
        /*
        do {
            ...
        } catch {
            ...
        }
        */"""

content = content.replace(add_block, add_replacement)

# Replace deleteNote block
delete_block = """        // 2. Perform background synchronization to Supabase table "client_notes"
        do {
            try await client
                .from("client_notes")
                .delete()
                .eq("id", value: noteId.uuidString)
                .execute()
            print("Successfully deleted note from Supabase.")
        } catch {
            print("Supabase delete note warning: \\(error.localizedDescription)")
        }"""
        
delete_replacement = """        // 2. Perform background synchronization disabled (table 'client_notes' not in schema)"""

content = content.replace(delete_block, delete_replacement)

# Replace updateNote block
update_block = """        // 2. Perform background sync to Supabase
        do {
            try await client
                .from("client_notes")
                .update(["note": noteText])
                .eq("id", value: noteId.uuidString)
                .execute()
            print("Successfully updated note on Supabase.")
        } catch {
            print("Supabase update note warning: \\(error.localizedDescription)")
        }"""

update_replacement = """        // 2. Perform background sync disabled (table 'client_notes' not in schema)"""

content = content.replace(update_block, update_replacement)

with open("luxury/Core/SalesAssociate/Clienteling/Services/NotesService.swift", "w") as f:
    f.write(content)

