export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  public: {
    Tables: {
      admin_users: {
        Row: {
          id: string
          profile_id: string
          permissions: string
          created_at: string
        }
        Insert: {
          id?: string
          profile_id: string
          permissions?: string
          created_at?: string
        }
        Update: {
          id?: string
          profile_id?: string
          permissions?: string
          created_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "admin_users_profile_id_fkey"
            columns: ["profile_id"]
            isOneToOne: true
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      contract_deliveries: {
        Row: {
          id: string
          contract_id: string
          expected_date: string
          actual_date: string | null
          expected_quantity: number
          actual_quantity: number | null
          status: string
          farmer_notes: string | null
          store_notes: string | null
          quality_rating: number | null
          order_id: string | null
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          contract_id: string
          expected_date: string
          actual_date?: string | null
          expected_quantity: number
          actual_quantity?: number | null
          status?: string
          farmer_notes?: string | null
          store_notes?: string | null
          quality_rating?: number | null
          order_id?: string | null
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          contract_id?: string
          expected_date?: string
          actual_date?: string | null
          expected_quantity?: number
          actual_quantity?: number | null
          status?: string
          farmer_notes?: string | null
          store_notes?: string | null
          quality_rating?: number | null
          order_id?: string | null
          created_at?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "contract_deliveries_contract_id_fkey"
            columns: ["contract_id"]
            isOneToOne: false
            referencedRelation: "contracts"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "contract_deliveries_order_id_fkey"
            columns: ["order_id"]
            isOneToOne: false
            referencedRelation: "orders"
            referencedColumns: ["id"]
          },
        ]
      }
      contracts: {
        Row: {
          id: string
          store_id: string
          farmer_id: string | null
          product_id: string
          variety_id: string | null
          quantity_per_delivery: number
          unit_id: string
          price_per_unit: number
          currency_code: string
          delivery_frequency: string
          custom_frequency_days: number | null
          quality_standards: string | null
          payment_terms: string | null
          start_date: string
          end_date: string
          total_contracted_qty: number | null
          total_delivered_qty: number
          fulfillment_rate: number
          status: string
          is_public: boolean
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          store_id: string
          farmer_id?: string | null
          product_id: string
          variety_id?: string | null
          quantity_per_delivery: number
          unit_id: string
          price_per_unit: number
          currency_code?: string
          delivery_frequency: string
          custom_frequency_days?: number | null
          quality_standards?: string | null
          payment_terms?: string | null
          start_date: string
          end_date: string
          total_contracted_qty?: number | null
          total_delivered_qty?: number
          fulfillment_rate?: number
          status?: string
          is_public?: boolean
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          store_id?: string
          farmer_id?: string | null
          product_id?: string
          variety_id?: string | null
          quantity_per_delivery?: number
          unit_id?: string
          price_per_unit?: number
          currency_code?: string
          delivery_frequency?: string
          custom_frequency_days?: number | null
          quality_standards?: string | null
          payment_terms?: string | null
          start_date?: string
          end_date?: string
          total_contracted_qty?: number | null
          total_delivered_qty?: number
          fulfillment_rate?: number
          status?: string
          is_public?: boolean
          created_at?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "contracts_store_id_fkey"
            columns: ["store_id"]
            isOneToOne: false
            referencedRelation: "stores"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "contracts_farmer_id_fkey"
            columns: ["farmer_id"]
            isOneToOne: false
            referencedRelation: "farmers"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "contracts_product_id_fkey"
            columns: ["product_id"]
            isOneToOne: false
            referencedRelation: "products"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "contracts_variety_id_fkey"
            columns: ["variety_id"]
            isOneToOne: false
            referencedRelation: "product_varieties"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "contracts_unit_id_fkey"
            columns: ["unit_id"]
            isOneToOne: false
            referencedRelation: "units_of_measure"
            referencedColumns: ["id"]
          },
        ]
      }
      countries: {
        Row: {
          id: string
          code: string
          name: string
          currency_id: string
          is_active: boolean
          created_at: string
        }
        Insert: {
          id?: string
          code: string
          name: string
          currency_id: string
          is_active?: boolean
          created_at?: string
        }
        Update: {
          id?: string
          code?: string
          name?: string
          currency_id?: string
          is_active?: boolean
          created_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "countries_currency_id_fkey"
            columns: ["currency_id"]
            isOneToOne: false
            referencedRelation: "currencies"
            referencedColumns: ["id"]
          },
        ]
      }
      cropping_plans: {
        Row: {
          id: string
          farmer_id: string
          product_id: string
          variety_id: string | null
          date_planted: string
          expected_harvest_date: string
          estimated_yield: number | null
          yield_unit_id: string | null
          actual_yield: number | null
          growing_status: string
          is_contracted: boolean
          contract_id: string | null
          notes: string | null
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          farmer_id: string
          product_id: string
          variety_id?: string | null
          date_planted: string
          expected_harvest_date: string
          estimated_yield?: number | null
          yield_unit_id?: string | null
          actual_yield?: number | null
          growing_status?: string
          is_contracted?: boolean
          contract_id?: string | null
          notes?: string | null
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          farmer_id?: string
          product_id?: string
          variety_id?: string | null
          date_planted?: string
          expected_harvest_date?: string
          estimated_yield?: number | null
          yield_unit_id?: string | null
          actual_yield?: number | null
          growing_status?: string
          is_contracted?: boolean
          contract_id?: string | null
          notes?: string | null
          created_at?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "cropping_plans_farmer_id_fkey"
            columns: ["farmer_id"]
            isOneToOne: false
            referencedRelation: "farmers"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "cropping_plans_product_id_fkey"
            columns: ["product_id"]
            isOneToOne: false
            referencedRelation: "products"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "cropping_plans_variety_id_fkey"
            columns: ["variety_id"]
            isOneToOne: false
            referencedRelation: "product_varieties"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "cropping_plans_yield_unit_id_fkey"
            columns: ["yield_unit_id"]
            isOneToOne: false
            referencedRelation: "units_of_measure"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "cropping_plans_contract_id_fkey"
            columns: ["contract_id"]
            isOneToOne: false
            referencedRelation: "contracts"
            referencedColumns: ["id"]
          },
        ]
      }
      currencies: {
        Row: {
          id: string
          code: string
          name: string
          symbol: string
          decimal_precision: number
          is_active: boolean
          created_at: string
        }
        Insert: {
          id?: string
          code: string
          name: string
          symbol: string
          decimal_precision?: number
          is_active?: boolean
          created_at?: string
        }
        Update: {
          id?: string
          code?: string
          name?: string
          symbol?: string
          decimal_precision?: number
          is_active?: boolean
          created_at?: string
        }
        Relationships: []
      }
      farm_images: {
        Row: {
          id: string
          farmer_id: string
          image_url: string
          is_primary: boolean
          created_at: string
        }
        Insert: {
          id?: string
          farmer_id: string
          image_url: string
          is_primary?: boolean
          created_at?: string
        }
        Update: {
          id?: string
          farmer_id?: string
          image_url?: string
          is_primary?: boolean
          created_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "farm_images_farmer_id_fkey"
            columns: ["farmer_id"]
            isOneToOne: false
            referencedRelation: "farmers"
            referencedColumns: ["id"]
          },
        ]
      }
      farmer_products: {
        Row: {
          id: string
          farmer_id: string
          product_id: string
          created_at: string
        }
        Insert: {
          id?: string
          farmer_id: string
          product_id: string
          created_at?: string
        }
        Update: {
          id?: string
          farmer_id?: string
          product_id?: string
          created_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "farmer_products_farmer_id_fkey"
            columns: ["farmer_id"]
            isOneToOne: false
            referencedRelation: "farmers"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "farmer_products_product_id_fkey"
            columns: ["product_id"]
            isOneToOne: false
            referencedRelation: "products"
            referencedColumns: ["id"]
          },
        ]
      }
      farmers: {
        Row: {
          id: string
          profile_id: string
          farm_name: string
          farm_location_lat: number | null
          farm_location_lng: number | null
          farm_address: string | null
          country_id: string | null
          farm_size: string | null
          farm_size_unit: string | null
          id_number: string | null
          bio: string | null
          verification_status: string
          rejection_reason: string | null
          verified_at: string | null
          verified_by: string | null
          avg_overall_rating: number
          avg_quality_rating: number
          avg_reliability_rating: number
          total_reviews: number
          total_transactions: number
          contract_fulfillment_rate: number
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          profile_id: string
          farm_name: string
          farm_location_lat?: number | null
          farm_location_lng?: number | null
          farm_address?: string | null
          country_id?: string | null
          farm_size?: string | null
          farm_size_unit?: string | null
          id_number?: string | null
          bio?: string | null
          verification_status?: string
          rejection_reason?: string | null
          verified_at?: string | null
          verified_by?: string | null
          avg_overall_rating?: number
          avg_quality_rating?: number
          avg_reliability_rating?: number
          total_reviews?: number
          total_transactions?: number
          contract_fulfillment_rate?: number
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          profile_id?: string
          farm_name?: string
          farm_location_lat?: number | null
          farm_location_lng?: number | null
          farm_address?: string | null
          country_id?: string | null
          farm_size?: string | null
          farm_size_unit?: string | null
          id_number?: string | null
          bio?: string | null
          verification_status?: string
          rejection_reason?: string | null
          verified_at?: string | null
          verified_by?: string | null
          avg_overall_rating?: number
          avg_quality_rating?: number
          avg_reliability_rating?: number
          total_reviews?: number
          total_transactions?: number
          contract_fulfillment_rate?: number
          created_at?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "farmers_profile_id_fkey"
            columns: ["profile_id"]
            isOneToOne: true
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "farmers_country_id_fkey"
            columns: ["country_id"]
            isOneToOne: false
            referencedRelation: "countries"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "farmers_verified_by_fkey"
            columns: ["verified_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      listing_images: {
        Row: {
          id: string
          listing_id: string
          image_url: string
          sort_order: number
          created_at: string
        }
        Insert: {
          id?: string
          listing_id: string
          image_url: string
          sort_order?: number
          created_at?: string
        }
        Update: {
          id?: string
          listing_id?: string
          image_url?: string
          sort_order?: number
          created_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "listing_images_listing_id_fkey"
            columns: ["listing_id"]
            isOneToOne: false
            referencedRelation: "listings"
            referencedColumns: ["id"]
          },
        ]
      }
      listings: {
        Row: {
          id: string
          farmer_id: string
          product_id: string
          variety_id: string | null
          title: string | null
          description: string | null
          quantity: number
          quantity_remaining: number
          unit_id: string
          price_per_unit: number
          currency_code: string
          quality_grade: string | null
          available_from: string
          available_until: string
          delivery_options: string
          status: string
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          farmer_id: string
          product_id: string
          variety_id?: string | null
          title?: string | null
          description?: string | null
          quantity: number
          quantity_remaining: number
          unit_id: string
          price_per_unit: number
          currency_code?: string
          quality_grade?: string | null
          available_from: string
          available_until: string
          delivery_options?: string
          status?: string
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          farmer_id?: string
          product_id?: string
          variety_id?: string | null
          title?: string | null
          description?: string | null
          quantity?: number
          quantity_remaining?: number
          unit_id?: string
          price_per_unit?: number
          currency_code?: string
          quality_grade?: string | null
          available_from?: string
          available_until?: string
          delivery_options?: string
          status?: string
          created_at?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "listings_farmer_id_fkey"
            columns: ["farmer_id"]
            isOneToOne: false
            referencedRelation: "farmers"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "listings_product_id_fkey"
            columns: ["product_id"]
            isOneToOne: false
            referencedRelation: "products"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "listings_variety_id_fkey"
            columns: ["variety_id"]
            isOneToOne: false
            referencedRelation: "product_varieties"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "listings_unit_id_fkey"
            columns: ["unit_id"]
            isOneToOne: false
            referencedRelation: "units_of_measure"
            referencedColumns: ["id"]
          },
        ]
      }
      notifications: {
        Row: {
          id: string
          recipient_id: string
          type: string
          title: string
          body: string
          data: Json | null
          channel: string
          is_read: boolean
          push_sent: boolean
          whatsapp_sent: boolean
          created_at: string
        }
        Insert: {
          id?: string
          recipient_id: string
          type: string
          title: string
          body: string
          data?: Json | null
          channel: string
          is_read?: boolean
          push_sent?: boolean
          whatsapp_sent?: boolean
          created_at?: string
        }
        Update: {
          id?: string
          recipient_id?: string
          type?: string
          title?: string
          body?: string
          data?: Json | null
          channel?: string
          is_read?: boolean
          push_sent?: boolean
          whatsapp_sent?: boolean
          created_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "notifications_recipient_id_fkey"
            columns: ["recipient_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      order_items: {
        Row: {
          id: string
          order_id: string
          product_id: string
          variety_id: string | null
          quantity: number
          unit_id: string
          price_per_unit: number
          currency_code: string
          line_total: number
          actual_qty_received: number | null
          quality_notes: string | null
          created_at: string
        }
        Insert: {
          id?: string
          order_id: string
          product_id: string
          variety_id?: string | null
          quantity: number
          unit_id: string
          price_per_unit: number
          currency_code?: string
          line_total: number
          actual_qty_received?: number | null
          quality_notes?: string | null
          created_at?: string
        }
        Update: {
          id?: string
          order_id?: string
          product_id?: string
          variety_id?: string | null
          quantity?: number
          unit_id?: string
          price_per_unit?: number
          currency_code?: string
          line_total?: number
          actual_qty_received?: number | null
          quality_notes?: string | null
          created_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "order_items_order_id_fkey"
            columns: ["order_id"]
            isOneToOne: false
            referencedRelation: "orders"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "order_items_product_id_fkey"
            columns: ["product_id"]
            isOneToOne: false
            referencedRelation: "products"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "order_items_variety_id_fkey"
            columns: ["variety_id"]
            isOneToOne: false
            referencedRelation: "product_varieties"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "order_items_unit_id_fkey"
            columns: ["unit_id"]
            isOneToOne: false
            referencedRelation: "units_of_measure"
            referencedColumns: ["id"]
          },
        ]
      }
      orders: {
        Row: {
          id: string
          order_number: string
          store_id: string
          farmer_id: string
          source: string
          listing_id: string | null
          tender_offer_id: string | null
          contract_delivery_id: string | null
          delivery_method: string
          delivery_date: string | null
          delivery_address: string | null
          pickup_address: string | null
          subtotal: number
          currency_code: string
          commission_rate: number
          commission_amount: number
          status: string
          payment_status: string
          payment_method: string | null
          actual_qty_received: number | null
          store_notes: string | null
          farmer_notes: string | null
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          order_number: string
          store_id: string
          farmer_id: string
          source: string
          listing_id?: string | null
          tender_offer_id?: string | null
          contract_delivery_id?: string | null
          delivery_method: string
          delivery_date?: string | null
          delivery_address?: string | null
          pickup_address?: string | null
          subtotal: number
          currency_code?: string
          commission_rate?: number
          commission_amount?: number
          status?: string
          payment_status?: string
          payment_method?: string | null
          actual_qty_received?: number | null
          store_notes?: string | null
          farmer_notes?: string | null
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          order_number?: string
          store_id?: string
          farmer_id?: string
          source?: string
          listing_id?: string | null
          tender_offer_id?: string | null
          contract_delivery_id?: string | null
          delivery_method?: string
          delivery_date?: string | null
          delivery_address?: string | null
          pickup_address?: string | null
          subtotal?: number
          currency_code?: string
          commission_rate?: number
          commission_amount?: number
          status?: string
          payment_status?: string
          payment_method?: string | null
          actual_qty_received?: number | null
          store_notes?: string | null
          farmer_notes?: string | null
          created_at?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "orders_store_id_fkey"
            columns: ["store_id"]
            isOneToOne: false
            referencedRelation: "stores"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "orders_farmer_id_fkey"
            columns: ["farmer_id"]
            isOneToOne: false
            referencedRelation: "farmers"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "orders_listing_id_fkey"
            columns: ["listing_id"]
            isOneToOne: false
            referencedRelation: "listings"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "orders_tender_offer_id_fkey"
            columns: ["tender_offer_id"]
            isOneToOne: false
            referencedRelation: "tender_offers"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "orders_contract_delivery_id_fkey"
            columns: ["contract_delivery_id"]
            isOneToOne: false
            referencedRelation: "contract_deliveries"
            referencedColumns: ["id"]
          },
        ]
      }
      platform_settings: {
        Row: {
          id: string
          key: string
          value: string
          description: string | null
          updated_at: string
          updated_by: string | null
        }
        Insert: {
          id?: string
          key: string
          value: string
          description?: string | null
          updated_at?: string
          updated_by?: string | null
        }
        Update: {
          id?: string
          key?: string
          value?: string
          description?: string | null
          updated_at?: string
          updated_by?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "platform_settings_updated_by_fkey"
            columns: ["updated_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      product_categories: {
        Row: {
          id: string
          name: string
          description: string | null
          icon_url: string | null
          sort_order: number
          is_active: boolean
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          name: string
          description?: string | null
          icon_url?: string | null
          sort_order?: number
          is_active?: boolean
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          name?: string
          description?: string | null
          icon_url?: string | null
          sort_order?: number
          is_active?: boolean
          created_at?: string
          updated_at?: string
        }
        Relationships: []
      }
      product_requests: {
        Row: {
          id: string
          farmer_id: string
          product_name: string
          suggested_category_id: string | null
          description: string | null
          status: string
          admin_notes: string | null
          reviewed_by: string | null
          reviewed_at: string | null
          created_product_id: string | null
          created_at: string
        }
        Insert: {
          id?: string
          farmer_id: string
          product_name: string
          suggested_category_id?: string | null
          description?: string | null
          status?: string
          admin_notes?: string | null
          reviewed_by?: string | null
          reviewed_at?: string | null
          created_product_id?: string | null
          created_at?: string
        }
        Update: {
          id?: string
          farmer_id?: string
          product_name?: string
          suggested_category_id?: string | null
          description?: string | null
          status?: string
          admin_notes?: string | null
          reviewed_by?: string | null
          reviewed_at?: string | null
          created_product_id?: string | null
          created_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "product_requests_farmer_id_fkey"
            columns: ["farmer_id"]
            isOneToOne: false
            referencedRelation: "farmers"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "product_requests_suggested_category_id_fkey"
            columns: ["suggested_category_id"]
            isOneToOne: false
            referencedRelation: "product_categories"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "product_requests_reviewed_by_fkey"
            columns: ["reviewed_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "product_requests_created_product_id_fkey"
            columns: ["created_product_id"]
            isOneToOne: false
            referencedRelation: "products"
            referencedColumns: ["id"]
          },
        ]
      }
      product_varieties: {
        Row: {
          id: string
          product_id: string
          name: string
          description: string | null
          is_active: boolean
          created_at: string
        }
        Insert: {
          id?: string
          product_id: string
          name: string
          description?: string | null
          is_active?: boolean
          created_at?: string
        }
        Update: {
          id?: string
          product_id?: string
          name?: string
          description?: string | null
          is_active?: boolean
          created_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "product_varieties_product_id_fkey"
            columns: ["product_id"]
            isOneToOne: false
            referencedRelation: "products"
            referencedColumns: ["id"]
          },
        ]
      }
      products: {
        Row: {
          id: string
          category_id: string
          name: string
          description: string | null
          image_url: string | null
          sort_order: number
          is_active: boolean
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          category_id: string
          name: string
          description?: string | null
          image_url?: string | null
          sort_order?: number
          is_active?: boolean
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          category_id?: string
          name?: string
          description?: string | null
          image_url?: string | null
          sort_order?: number
          is_active?: boolean
          created_at?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "products_category_id_fkey"
            columns: ["category_id"]
            isOneToOne: false
            referencedRelation: "product_categories"
            referencedColumns: ["id"]
          },
        ]
      }
      profiles: {
        Row: {
          id: string
          phone: string
          email: string | null
          full_name: string
          avatar_url: string | null
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          phone: string
          email?: string | null
          full_name: string
          avatar_url?: string | null
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          phone?: string
          email?: string | null
          full_name?: string
          avatar_url?: string | null
          created_at?: string
          updated_at?: string
        }
        Relationships: []
      }
      reviews: {
        Row: {
          id: string
          order_id: string
          store_id: string
          farmer_id: string
          overall_rating: number
          quality_rating: number
          reliability_rating: number
          comment: string | null
          created_at: string
        }
        Insert: {
          id?: string
          order_id: string
          store_id: string
          farmer_id: string
          overall_rating: number
          quality_rating: number
          reliability_rating: number
          comment?: string | null
          created_at?: string
        }
        Update: {
          id?: string
          order_id?: string
          store_id?: string
          farmer_id?: string
          overall_rating?: number
          quality_rating?: number
          reliability_rating?: number
          comment?: string | null
          created_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "reviews_order_id_fkey"
            columns: ["order_id"]
            isOneToOne: true
            referencedRelation: "orders"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "reviews_store_id_fkey"
            columns: ["store_id"]
            isOneToOne: false
            referencedRelation: "stores"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "reviews_farmer_id_fkey"
            columns: ["farmer_id"]
            isOneToOne: false
            referencedRelation: "farmers"
            referencedColumns: ["id"]
          },
        ]
      }
      stores: {
        Row: {
          id: string
          profile_id: string
          business_name: string
          store_type: string
          location_lat: number | null
          location_lng: number | null
          address: string | null
          country_id: string | null
          contact_phone: string | null
          contact_email: string | null
          bio: string | null
          logo_url: string | null
          is_active: boolean
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          profile_id: string
          business_name: string
          store_type: string
          location_lat?: number | null
          location_lng?: number | null
          address?: string | null
          country_id?: string | null
          contact_phone?: string | null
          contact_email?: string | null
          bio?: string | null
          logo_url?: string | null
          is_active?: boolean
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          profile_id?: string
          business_name?: string
          store_type?: string
          location_lat?: number | null
          location_lng?: number | null
          address?: string | null
          country_id?: string | null
          contact_phone?: string | null
          contact_email?: string | null
          bio?: string | null
          logo_url?: string | null
          is_active?: boolean
          created_at?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "stores_profile_id_fkey"
            columns: ["profile_id"]
            isOneToOne: true
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "stores_country_id_fkey"
            columns: ["country_id"]
            isOneToOne: false
            referencedRelation: "countries"
            referencedColumns: ["id"]
          },
        ]
      }
      tender_offers: {
        Row: {
          id: string
          tender_id: string
          farmer_id: string
          quantity_offered: number
          price_per_unit: number
          currency_code: string
          delivery_date: string
          delivery_method: string
          notes: string | null
          status: string
          responded_at: string | null
          created_at: string
        }
        Insert: {
          id?: string
          tender_id: string
          farmer_id: string
          quantity_offered: number
          price_per_unit: number
          currency_code?: string
          delivery_date: string
          delivery_method?: string
          notes?: string | null
          status?: string
          responded_at?: string | null
          created_at?: string
        }
        Update: {
          id?: string
          tender_id?: string
          farmer_id?: string
          quantity_offered?: number
          price_per_unit?: number
          currency_code?: string
          delivery_date?: string
          delivery_method?: string
          notes?: string | null
          status?: string
          responded_at?: string | null
          created_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "tender_offers_tender_id_fkey"
            columns: ["tender_id"]
            isOneToOne: false
            referencedRelation: "tenders"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "tender_offers_farmer_id_fkey"
            columns: ["farmer_id"]
            isOneToOne: false
            referencedRelation: "farmers"
            referencedColumns: ["id"]
          },
        ]
      }
      tenders: {
        Row: {
          id: string
          store_id: string
          product_id: string
          variety_id: string | null
          quantity_needed: number
          unit_id: string
          min_price: number | null
          max_price: number | null
          currency_code: string
          date_needed_by: string
          quality_requirements: string | null
          delivery_preference: string
          quantity_fulfilled: number
          status: string
          expires_at: string | null
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          store_id: string
          product_id: string
          variety_id?: string | null
          quantity_needed: number
          unit_id: string
          min_price?: number | null
          max_price?: number | null
          currency_code?: string
          date_needed_by: string
          quality_requirements?: string | null
          delivery_preference?: string
          quantity_fulfilled?: number
          status?: string
          expires_at?: string | null
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          store_id?: string
          product_id?: string
          variety_id?: string | null
          quantity_needed?: number
          unit_id?: string
          min_price?: number | null
          max_price?: number | null
          currency_code?: string
          date_needed_by?: string
          quality_requirements?: string | null
          delivery_preference?: string
          quantity_fulfilled?: number
          status?: string
          expires_at?: string | null
          created_at?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "tenders_store_id_fkey"
            columns: ["store_id"]
            isOneToOne: false
            referencedRelation: "stores"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "tenders_product_id_fkey"
            columns: ["product_id"]
            isOneToOne: false
            referencedRelation: "products"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "tenders_variety_id_fkey"
            columns: ["variety_id"]
            isOneToOne: false
            referencedRelation: "product_varieties"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "tenders_unit_id_fkey"
            columns: ["unit_id"]
            isOneToOne: false
            referencedRelation: "units_of_measure"
            referencedColumns: ["id"]
          },
        ]
      }
      units_of_measure: {
        Row: {
          id: string
          name: string
          abbreviation: string
          context: string
          sort_order: number
          is_active: boolean
          created_at: string
        }
        Insert: {
          id?: string
          name: string
          abbreviation: string
          context: string
          sort_order?: number
          is_active?: boolean
          created_at?: string
        }
        Update: {
          id?: string
          name?: string
          abbreviation?: string
          context?: string
          sort_order?: number
          is_active?: boolean
          created_at?: string
        }
        Relationships: []
      }
      user_roles: {
        Row: {
          id: string
          profile_id: string
          role: string
          is_active: boolean
          created_at: string
        }
        Insert: {
          id?: string
          profile_id: string
          role: string
          is_active?: boolean
          created_at?: string
        }
        Update: {
          id?: string
          profile_id?: string
          role?: string
          is_active?: boolean
          created_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "user_roles_profile_id_fkey"
            columns: ["profile_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      decrement_listing_quantity: {
        Args: {
          p_listing_id: string
          p_ordered_qty: number
        }
        Returns: number
      }
      increment_tender_fulfillment: {
        Args: {
          p_tender_id: string
          p_qty: number
        }
        Returns: number
      }
      update_contract_delivery_totals: {
        Args: {
          p_contract_id: string
          p_qty: number
        }
        Returns: undefined
      }
      assign_user_role: {
        Args: {
          p_profile_id: string
          p_role: string
        }
        Returns: undefined
      }
      is_admin: {
        Args: {
          p_profile_id: string
        }
        Returns: boolean
      }
      has_role: {
        Args: {
          p_profile_id: string
          p_role: string
        }
        Returns: boolean
      }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type PublicSchema = Database[Extract<keyof Database, "public">]

export type Tables<
  PublicTableNameOrOptions extends
    | keyof (PublicSchema["Tables"] & PublicSchema["Views"])
    | { schema: keyof Database },
  TableName extends PublicTableNameOrOptions extends { schema: keyof Database }
    ? keyof (Database[PublicTableNameOrOptions["schema"]]["Tables"] &
        Database[PublicTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = PublicTableNameOrOptions extends { schema: keyof Database }
  ? (Database[PublicTableNameOrOptions["schema"]]["Tables"] &
      Database[PublicTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : PublicTableNameOrOptions extends keyof (PublicSchema["Tables"] &
        PublicSchema["Views"])
    ? (PublicSchema["Tables"] &
        PublicSchema["Views"])[PublicTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  PublicTableNameOrOptions extends
    | keyof PublicSchema["Tables"]
    | { schema: keyof Database },
  TableName extends PublicTableNameOrOptions extends { schema: keyof Database }
    ? keyof Database[PublicTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = PublicTableNameOrOptions extends { schema: keyof Database }
  ? Database[PublicTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : PublicTableNameOrOptions extends keyof PublicSchema["Tables"]
    ? PublicSchema["Tables"][PublicTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  PublicTableNameOrOptions extends
    | keyof PublicSchema["Tables"]
    | { schema: keyof Database },
  TableName extends PublicTableNameOrOptions extends { schema: keyof Database }
    ? keyof Database[PublicTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = PublicTableNameOrOptions extends { schema: keyof Database }
  ? Database[PublicTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : PublicTableNameOrOptions extends keyof PublicSchema["Tables"]
    ? PublicSchema["Tables"][PublicTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  PublicEnumNameOrOptions extends
    | keyof PublicSchema["Enums"]
    | { schema: keyof Database },
  EnumName extends PublicEnumNameOrOptions extends { schema: keyof Database }
    ? keyof Database[PublicEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = PublicEnumNameOrOptions extends { schema: keyof Database }
  ? Database[PublicEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : PublicEnumNameOrOptions extends keyof PublicSchema["Enums"]
    ? PublicSchema["Enums"][PublicEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof PublicSchema["CompositeTypes"]
    | { schema: keyof Database },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof Database
  }
    ? keyof Database[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends { schema: keyof Database }
  ? Database[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof PublicSchema["CompositeTypes"]
    ? PublicSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never
