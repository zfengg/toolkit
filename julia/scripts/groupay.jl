#!/usr/bin/env julia

# ---------------------------------------------------------------------------- #
# groupay.jl :  A simple interactive group payment solution.
#
# Copyright: Zhou Feng @ https://github.com/zfengg/toolkit/tree/master/julia
# ---------------------------------------------------------------------------- #

using Dates

# ---------------------------- structs & functions --------------------------- #
# Member
mutable struct Member
    name::String
    shouldPay::Dict
    hasPaid::Dict
    Member(name::String) = new(name, Dict(), Dict())
end
get_toPay(m::Member) = sum(values(m.shouldPay)) - sum(values(m.hasPaid))

function print_member(m::Member)
    println("[\e[36m", m.name, "\e[0m]")
    println("-- has paid")
    for (k, v) in m.hasPaid
        println("\e[33m", k, "\e[0m : ", v)
    end
    println("total = \e[32m", sum(values(m.hasPaid)), "\e[0m")
    println("-- should pay")
    for (k, v) in m.shouldPay
        println("\e[33m", k, "\e[0m : ", v)
    end
    println("total = \e[31m", sum(values(m.shouldPay)), "\e[0m")
    println("-- remains to pay: \e[35m", get_toPay(m), "\e[0m\n")
end

# PayGroup
mutable struct PayGroup
    title::String
    date::Date
    members::Dict
    billMetaInfo::Dict
    billDetails::Dict
    PayGroup(title::String, date::Date) = new(title, date, Dict(), Dict(), Dict())
    PayGroup(title::String) = PayGroup(title, Dates.today())
end

function gen_paygrp()
    println("What's the name of your group?")
    title = readline()
    while isempty(title)
        println("Why not name your group? ^o^")
        print("Yes, you can give it a nice name: ")
        title = readline()
    end
    payGrp = PayGroup(title)
    println("And who are in the group \e[31m", title, "\e[0m?")
    members = String[]
    while true
        membersTmp = readline()
        append!(members, split(membersTmp))
        println()
        println("Your group now contains \e[31m", length(members), "\e[0m members:")
        for x in members
            println("\e[36m", x, "\e[0m")
        end
        println()
        println("Do you want to add more members?(y/[n])")
        flagInputName = readline()
        if flagInputName == "y"
            println()
            println("Please add the names of the others:")
        elseif length(members) == 0
            println()
            println("haha~ such a joke that a group with \e[31mNO\e[0m members!")
            println("Please add the names of the others:")
        else
            if length(members) == 1
                println("Cheer up! No shame being alone ~")
            end
            break
        end
    end

    for name in members
        push!(payGrp.members, name => Member(name))
    end

    return payGrp
end

function add_members!(payGrp::PayGroup)
    println("Here are the members in \e[31m", payGrp.title, "\e[0m:")
    for x in keys(payGrp.members)
        println("\e[36m", x, "\e[0m")
    end

    println("Who else do you want to add?")
    println("Warning: Repeated names may crash the whole process ^_^!")
    addMembers = String[]
    while true
        membersTmp = readline()
        append!(addMembers, split(membersTmp))

        println()
        println("The following \e[31m", length(addMembers), "\e[0m members are added:")
        for x in addMembers
            println("\e[36m", x, "\e[0m")
        end
        println()
        println("Do you what to add more members?(y/[n])")
        flagInputName = readline()
        if flagInputName == "y"
            println()
            println("Please add the names of the others:")
        else
            break
        end
    end

    for name in addMembers
        push!(payGrp.members, name => Member(name))
    end

    return payGrp
end

function get_bill_details(m::Dict, billname::String)
    billDetails = Dict()
    for (name, member) in m
        if haskey(member.shouldPay, billname)
            push!(billDetails, member.name => member.shouldPay[billname])
        end
    end
    return billDetails
end
get_bill_details(x::PayGroup, billname::String) = get_bill_details(x.members, billname)

function print_bill(x::PayGroup, billname::String)
    println("[\e[33m", billname, "\e[0m]")
    payTotal = x.billMetaInfo[billname][1]
    payMan = x.billMetaInfo[billname][2]
    println("total = \e[31m", payTotal, "\e[0m paid by \e[36m", payMan, "\e[0m;")
    if x.billMetaInfo[billname][3]
        println("-- \e[34mAA\e[0m --")
    else
        println("-- \e[34mnot AA\e[0m --")
    end
    for (key, val) in x.billDetails[billname]
        println("\e[36m", key, "\e[0m => ", val)
    end
    println()
end

function print_bills(x::PayGroup)
    println("\n======\n")
    for billname in keys(x.billDetails)
        print_bill(x, billname)
    end
    println("======\n")
end

function print_members(x::PayGroup)
    println("\n======\n")
    for member in values(x.members)
        print_member(member)
    end
    println("======\n")
end

function add_bills!(payGrp::PayGroup)
    println()
    println("Ok, nice to meet you all!")
    for x in keys(payGrp.members)
        println("\e[36m", x, "\e[0m")
    end
    println("Then let's review your bills together.")

    println()
    println("What's your first bill to add?")
    countBills = 1
    while true
        # meta info
        billname = readline()
        while isempty(billname)
            println("It's better to give the bill a name, right? ^o^")
            print("So please name your bill: ")
            billname = readline()
        end
        println("Who pays \e[33m", billname, "\e[0m?")
        payMan = undef
        while true
            payMan = readline()
            if payMan in keys(payGrp.members)
                break
            else
                println("Oops, \e[36m", payMan, "\e[0m is not in your group! Please input the name again:")
            end
        end
        println("And how much has \e[36m", payMan, "\e[0m paid?")
        tempExpr = Meta.parse(readline())
        payTotal = eval(tempExpr) |> Float64
        println(tempExpr, " = ", payTotal)
        for (name, member) in payGrp.members
            if name == payMan
                push!(member.hasPaid, billname => payTotal)
            else
                push!(member.hasPaid, billname => 0.)
            end
        end

        # details
        println("Do you \e[34mAA\e[0m?([y]/n)")
        isAA = readline()
        if isAA == "n"
            isAA = false
            billDetails = undef
            while true
                tmpMembers = copy(payGrp.members)
                println("How much should each member pay?")
                for (name, member) in tmpMembers
                    print("\e[36m", name, "\e[0m : ")
                    tempExpr = Meta.parse(readline())
                    tmpShouldPay = eval(tempExpr) |> Float64
                    println(tempExpr, " = ", tmpShouldPay)
                    push!(member.shouldPay, billname => tmpShouldPay)
                end

                billDetails = get_bill_details(tmpMembers, billname)
                if payTotal != sum(values(billDetails))
                    println()
                    println("Oops! It doesn't sum up to the total payment! Please input again.")
                else
                    payGrp.members = tmpMembers
                    break
                end
            end
        else
            isAA = true
            println("\e[34mAA\e[0m on all the members?([y]/n)")
            isAllAA = readline()
            AAlist = []
            if isAllAA == "n"
                println("Check [y]/n ?")
                for name in keys(payGrp.members)
                    print("\e[36m", name, "\e[0m : ")
                    tmpIsAA = readline()
                    if tmpIsAA != "n"
                        push!(AAlist, name)
                    end
                end
            else
                AAlist = keys(payGrp.members)
            end
            avgPay = payTotal / length(AAlist)
            for name in keys(payGrp.members)
                if name in AAlist
                    push!(payGrp.members[name].shouldPay, billname => avgPay)
                else
                    push!(payGrp.members[name].shouldPay, billname => 0.)
                end
            end
        end

        push!(payGrp.billMetaInfo, billname => (payTotal, payMan, isAA))
        billDetails = get_bill_details(payGrp, billname)
        push!(payGrp.billDetails, billname => billDetails)
        println()
        print_bill(payGrp, billname)

        println()
        println("And do you have another bill?([y]/n)")
        hasNextBill = readline()
        if hasNextBill == "n"
            break
        else
            countBills += 1
            println()
            println("What's your next bill?")
        end
    end
    return payGrp
end

## payment solution
function gen_soln(payGrp::PayGroup)
    payers = []
    receivers = []
    for (name, member) in payGrp.members
        tmpToPay = get_toPay(member)
        if tmpToPay == 0
            continue
        elseif tmpToPay > 0
            push!(payers, (name, tmpToPay))
        else
            push!(receivers, (name, -tmpToPay))
        end
    end
    payers = sort(payers; by=x -> x[2])
    receivers = sort(receivers; by=x -> x[2])
    if abs(sum(map(x -> x[2], payers)) - sum(map(x -> x[2], receivers))) > 0.01
        println("Source does NOT match sink!")
    end

    soln = []
    while ! isempty(receivers)
        tmpPayer = payers[end]
        tmpReceiver = receivers[end]
        tmpDiff = tmpPayer[2] - tmpReceiver[2]
        if tmpDiff > 0.001
            push!(soln, (tmpPayer[1], tmpReceiver[1], tmpReceiver[2]))
            pop!(receivers)
            payers[end] = (tmpPayer[1], tmpDiff)
        elseif tmpDiff < -0.001
            push!(soln, (tmpPayer[1], tmpReceiver[1], tmpPayer[2]))
            pop!(payers)
            receivers[end] = (tmpReceiver[1], - tmpDiff)
        else
            push!(soln, (tmpPayer[1], tmpReceiver[1], tmpPayer[2]))
            pop!(payers)
            pop!(receivers)
        end
    end
    return soln
end

function print_soln(soln)
    println("\nTada! Here is a \e[32mpayment solution\e[0m :)\n")
    for tuple in soln
        println("\e[36m", tuple[1], "\e[0m => \e[36m", tuple[2], "\e[0m : ", tuple[3])
    end
    println()
end


# ---------------------------------- main() ---------------------------------- #
# welcome
println("Hi, there! Welcome to happy ~\e[32m group pay \e[0m~")
println("We will provide you a payment solution for your group.")
println()

# input_members
payGrp = gen_paygrp()

# input_bills
payGrp = add_bills!(payGrp)

# print bills
println()
println("Show all the bills?([y]/n)")
ynFlag = readline()
if ynFlag == "n"
else
    print_bills(payGrp)
end

# print bills of members
println("And show all the bills based on members?([y]/n)")
ynFlag = readline()
if ynFlag == "n"
else
    print_members(payGrp)
end

# payment solution
soln = gen_soln(payGrp)
print_soln(soln)

# the end
println()
println("Have a good day ~")
