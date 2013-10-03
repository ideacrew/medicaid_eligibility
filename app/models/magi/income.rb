# encoding: UTF-8

module MAGI
  class Income < Ruleset
    name        "Determine MAGI Eligibility"
    mandatory   "Mandatory"
    applies_to  "Medicaid and CHIP"
    
    input "Applicant Adult Group Category Indicator", "From MAGI Part I", "Char(1)", %w(Y N)
    input "Applicant Pregnancy Category Indicator", "From MAGI Part I", "Char(1)", %w(Y N)
    input "Applicant Parent Caretaker Category Indicator", "From MAGI Part I", "Char(1)", %w(Y N)
    input "Applicant Child Category Indicator", "From MAGI Part I", "Char(1)", %w(Y N)
    input "Applicant Optional Targeted Low Income Child Indicator", "From MAGI Part I", "Char(1)", %w(Y N X)
    input "Applicant CHIP Targeted Low Income Child Indicator", "From MAGI Part I", "Char(1)", %w(Y N X)
    input "Calculated Income", "Medicaid Household Income Logic", "Integer"
    input "Medicaid Household", "Householding Logic", "Array"
    input "Applicant Age", "From application", "Integer"

    config "Base FPL", "State Configuration", "Integer"
    config "FPL Per Person", "State Configuration", "Integer"
    config "Option CHIP Pregnancy Category", "State Configuration", "Char(1)", %w(Y N)
    config "Medicaid Thresholds", "State Configuration", "Hash"
    config "CHIP Thresholds", "State Configuration", "Hash"

    # Outputs
    output    "Category Used to Calculate Medicaid Income", "String"
    indicator "Applicant Income Medicaid Eligible Indicator", %w(Y N)
    date      "Income Medicaid Eligible Determination Date"
    code      "Income Medicaid Eligible Ineligibility Reason", %w(999 A B)
    output    "Category Used to Calculate CHIP Income", "String"
    indicator "Applicant Income CHIP Eligible Indicator", %w(Y N)
    date      "Income CHIP Eligible Determination Date"
    code      "Income CHIP Eligible Ineligibility Reason", %w(999 A B)

    calculated "FPL" do
      c("Base FPL") + (v("Medicaid Household").household_size - 1) * c("FPL Per Person")
    end

    module Customizations
      def get_income(threshold, percentage, monthly)
        if percentage == 'Y'
          return (threshold + 5) * 0.01 * v("FPL")
        elsif percentage == 'N'
          if monthly == 'Y'
            return threshold * 12 + 0.05 * v("FPL")
          else
            return threshold + 0.05 * v("FPL")
          end
        else
          raise "Invalid state config"
        end
      end

      def get_threshold(category)
        if category["method"] == "standard"
          threshold = category["threshold"]
        elsif category["method"] == "household_size"
          thresholds = category["household_size"]
          household_size = v("Medicaid Household").household_size
          if household_size < thresholds.length
            threshold = thresholds[household_size]
          else
            threshold = thresholds.last + (household_size - thresholds.length + 1) * category["additional person"]
          end
        elsif category["method"] == "age"
          age_group = category["age"].find{|group| v("Applicant Age") >= group["minimum"] && v("Applicant Age") <= group["maximum"]}
          if age_group
            threshold = age_group["threshold"]
          else
            raise "No threshold defined for applicant age #{v("Applicant Age")}"
          end
        else
          raise "Undefined threshold method #{category["method"]}"
        end
        get_income(threshold, category["percentage"], category["monthly"])
      end
    end

    def run(context)
      context.extend Customizations
      super context
    end

    calculated "Max Eligible Medicaid Category" do
      eligible_categories = c("Medicaid Thresholds").keys.select{|cat| v("Applicant #{cat} Indicator") == 'Y'}
      if eligible_categories.any?
        eligible_categories.max_by{|cat| get_threshold(c("Medicaid Thresholds")[cat])}
      else
        "None"
      end
    end

    calculated "Max Eligible Medicaid Income" do
      if v("Max Eligible Medicaid Category") != "None"
        get_threshold(c("Medicaid Thresholds")[v("Max Eligible Medicaid Category")])
      else
        0
      end
    end

    calculated "Max Eligible CHIP Category" do
      eligible_categories = c("CHIP Thresholds").keys.select{|cat| v("Applicant #{cat} Indicator") == 'Y'}
      if eligible_categories.any?
        eligible_categories.max_by{|cat| get_threshold(c("CHIP Thresholds")[cat])}
      else
        "None"
      end
    end

    calculated "Max Eligible CHIP Income" do
      if v("Max Eligible CHIP Category") != "None"
        get_threshold(c("CHIP Thresholds")[v("Max Eligible CHIP Category")])
      else
        0
      end
    end

    rule "Set percentage used" do
      o["Percentage for Medicaid Category Used"] = c("Medicaid Thresholds")[v("Max Eligible Medicaid Category")]
      o["Percentage for CHIP Category Used"] = c("CHIP Thresholds")[v("Max Eligible CHIP Category")]
    end

    rule "Set FPL * percentage" do
      o["FPL"] = v("FPL")
      o["FPL * Percentage Medicaid"] = v("Max Eligible Medicaid Income")
      o["FPL * Percentage CHIP"] = v("Max Eligible CHIP Income")
      o["Category Used to Calculate Medicaid Income"] = v("Max Eligible Medicaid Category")
      o["Category Used to Calculate CHIP Income"] = v("Max Eligible CHIP Category")
    end

    rule "Determine Income Eligibility" do
      if v("Max Eligible Medicaid Category") == "None"
        o["Applicant Income Medicaid Eligible Indicator"] = "N"
        o["Income Medicaid Eligible Determination Date"] = current_date
        o["Income Medicaid Eligible Ineligibility Reason"] = "Unimplemented"
      elsif v("Calculated Income") > v("Max Eligible Medicaid Income")
        o["Applicant Income Medicaid Eligible Indicator"] = "N"
        o["Income Medicaid Eligible Determination Date"] = current_date
        o["Income Medicaid Eligible Ineligibility Reason"] = "Unimplemented"
      else
        o["Applicant Income Medicaid Eligible Indicator"] = "Y"
        o["Income Medicaid Eligible Determination Date"] = current_date
        o["Income Medicaid Eligible Ineligibility Reason"] = 999
      end

      if v("Max Eligible CHIP Category") == "None"
        o["Applicant Income CHIP Eligible Indicator"] = "N"
        o["Income CHIP Eligible Determination Date"] = current_date
        o["Income CHIP Eligible Ineligibility Reason"] = "Unimplemented"
      elsif v("Calculated Income") > v("Max Eligible CHIP Income")
        o["Applicant Income CHIP Eligible Indicator"] = "N"
        o["Income CHIP Eligible Determination Date"] = current_date
        o["Income CHIP Eligible Ineligibility Reason"] = "Unimplemented"
      else
        o["Applicant Income CHIP Eligible Indicator"] = "Y"
        o["Income CHIP Eligible Determination Date"] = current_date
        o["Income CHIP Eligible Ineligibility Reason"] = 999
      end
    end
  end
end
