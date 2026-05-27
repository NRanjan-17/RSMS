//
//  NotesService.swift
//  luxury
//
//  Created by Antigravity on 26/05/26.
//

import Foundation
import Supabase

struct DBClientNote: Codable {
    let id: UUID
    let clientId: UUID
    let note: String
    let date: String
    let author: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case clientId = "client_id"
        case note
        case date
        case author
    }
}

final class NotesService {
    static let shared = NotesService()
    private let client = SupabaseManager.shared.client
    
    private init() {}
    
    private func localKey(for clientId: UUID) -> String {
        return "luxury_notes_\(clientId.uuidString)"
    }
    
    func fetchNotes(clientId: UUID) -> [ClientNote] {
        let key = localKey(for: clientId)
        if let data = UserDefaults.standard.data(forKey: key) {
            do {
                return try JSONDecoder().decode([ClientNote].self, from: data)
            } catch {
                print("Error decoding local notes: \(error)")
            }
        }
        return []
    }
    
    func saveLocalNotes(_ notes: [ClientNote], for clientId: UUID) {
        let key = localKey(for: clientId)
        do {
            let data = try JSONEncoder().encode(notes)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("Error encoding local notes: \(error)")
        }
    }
    
    func syncNotes(clientId: UUID) async {
        do {
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
            print("Supabase fetch client_notes warning: \(error.localizedDescription)")
        }
    }
    
    func addNote(clientId: UUID, noteText: String, author: String = "Arjun Singh") async {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd"
        let dateStr = formatter.string(from: Date())
        
        let newNote = ClientNote(note: noteText, date: dateStr, author: author)
        
        var current = fetchNotes(clientId: clientId)
        current.insert(newNote, at: 0)
        saveLocalNotes(current, for: clientId)
        
        // Sync to Supabase in background
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
            print("Supabase notes sync warning: \(error.localizedDescription)")
        }
    }
    
    func deleteNote(clientId: UUID, noteId: UUID) async {
        // 1. Update local storage immediately for responsive UI
        var current = fetchNotes(clientId: clientId)
        current.removeAll { $0.id == noteId }
        saveLocalNotes(current, for: clientId)
        
        // 2. Perform background synchronization to Supabase table "client_notes"
        do {
            try await client
                .from("client_notes")
                .delete()
                .eq("id", value: noteId.uuidString)
                .execute()
            print("Successfully deleted note from Supabase.")
        } catch {
            print("Supabase delete note warning: \(error.localizedDescription)")
        }
    }
    
    func updateNote(clientId: UUID, noteId: UUID, noteText: String) async {
        // 1. Update local storage
        var current = fetchNotes(clientId: clientId)
        if let idx = current.firstIndex(where: { $0.id == noteId }) {
            current[idx].note = noteText
            saveLocalNotes(current, for: clientId)
        }
        
        // 2. Perform background sync to Supabase
        do {
            try await client
                .from("client_notes")
                .update(["note": noteText])
                .eq("id", value: noteId.uuidString)
                .execute()
            print("Successfully updated note on Supabase.")
        } catch {
            print("Supabase update note warning: \(error.localizedDescription)")
        }
    }
}
