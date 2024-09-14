//
//  Supabase.swift
//  songsurprise
//
//  Created by resoul on 11.09.2024.
//

import Supabase
import Foundation

let supabase = SupabaseClient(
    supabaseURL: URL(string: Environment.BASE_URL)!,
    supabaseKey: Environment.ANON_KEY
)
