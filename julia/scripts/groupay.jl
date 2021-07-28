#!/usr/bin/env julia
using Dates

# structs and functions
mutable struct Member
    name::String
    shouldPay::Dict
    hasPaid::Dict
    Member(name::String) = new(name, Dict(), Dict())
end
getToPay(m::Member) = sum(values(m.shouldPay)) - sum(values(m.hasPaid))

mutable struct PayGroup
    title::String
    date::Date
    members::Dict
    billMetaInfo::Dict
    billDetails::Dict
    PayGroup(title::String, date::Date) = new(title, date, Dict(), Dict(), Dict())
    PayGroup(title::String) = PayGroup(title, Dates.today())
end

function getBillDetails(m::Dict, billname::String)
    billDetails = Dict()
    for (name, member) in m
        if haskey(member.shouldPay, billname)
            push!(billDetails, member.name => member.shouldPay[billname])
        end
    end
    return billDetails
end
getBillDetails(x::PayGroup, billname::String) = getBillDetails(x.members, billname)


function print_bill(x::PayGroup, billname::String)
    println()
    println("[\e[33m", billname, "\e[0m]")
    payTotal = x.billMetaInfo[billname][1]
    payMan = x.billMetaInfo[billname][2]
    println("total: ", payTotal, " paid by \e[36m", payMan, "\e[0m;")
    if x.billMetaInfo[billname][3]
        println("-- \e[34mAA\e[0m --")
    else
        println("-- \e[34mnot AA\e[0m --")
    end
    for (key, val) in x.billDetails[billname]
        println(key, " => ", val)
    end
end

function print_allbills(x::PayGroup)
    for billname in keys(x.billDetails)
        print_bill(x, billname)
    end
end

function pay_soln(payGrp::PayGroup)
    payers = []
    receivers = []
    for (name, member) in payGrp.members
        tmpToPay = getToPay(member)
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
    println("\nHere is a \e[32mpayment solution\e[0m:\n")
    for tuple in soln
        println(tuple[1], " => ", tuple[2], " : ", tuple[3])
    end
    println()
end

function input_members()
    println("What's the name of your group?")
    title = readline()
    payGrp = PayGroup(title)
    println("And who are in your group?")
    members = String[]
    while true
        membersTmp = readline()
        append!(members, split(membersTmp))
        println()
        println("Your group now contains ", length(members), " members:")
        for name in members
            println(name)
        end
        println()
        println("Do you what to add more members?(y/[n])")
        flagInputName = readline()
        if flagInputName != "y"
            break
        end

        println()
        println("Please add the names of other members:")
    end

    for name in members
        push!(payGrp.members, name => Member(name))
    end

    return payGrp
end


function input_bills(payGrp::PayGroup)
    println()
    println("Ok, nice to meet you all!")
    println("Then let's review your bills together.")

    println()
    println("What's your first bill?")
    countBills = 1
    while true
        # meta info
        billname = readline()
        println("Who pays \e[32m", billname, "\e[0m?")
        payMan = undef
        while true
            payMan = readline()
            if payMan in keys(payGrp.members)
                break
            else
                println("Oops, \e[31m", payMan, "\e[0m is not in your group! Please reinput the name:")
            end
        end
        println("And how much?")
        payTotal = parse(Float64, readline())
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
                    print(name, " : ")
                    tempExpr = Meta.parse(readline())
                    tmpShouldPay = eval(tempExpr) |> Float64
                    println(tempExpr, " = ", tmpShouldPay)
                    push!(member.shouldPay, billname => tmpShouldPay)
                end

                billDetails = getBillDetails(tmpMembers, billname)
                if payTotal != sum(values(billDetails))
                    println()
                    println("Oops! It doesn't sum up to the total payment! Please reinput:")
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
                    print(name, " : ")
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
        billDetails = getBillDetails(payGrp, billname)
        push!(payGrp.billDetails, billname => billDetails)
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

function print_member(m::Member)
    println("[\e[36m", m.name, "\e[0m]")
    println("-- has paid --")
    for (k, v) in m.hasPaid
        println("\e[33m", k, "\e[0m : ", v)
    end
    println("total: \e[32m", sum(values(m.hasPaid)), "\e[0m")
    println("-- should pay --")
    for (k, v) in m.shouldPay
        println("\e[33m", k, "\e[0m : ", v)
    end
    println("total: \e[31m", sum(values(m.shouldPay)), "\e[0m")
    println("--")
    println("remains to pay: \e[35m", getToPay(m), "\e[0m")
    println()
end


# main()
# welcome
println("Hi, there! Welcome to happy ~\e[32m group pay \e[0m~")
println("We will provide you a payment solution for your group.")
println()

# input_members
payGrp = input_members()

# input_bills
payGrp = input_bills(payGrp)

# print bills of memembers
println("Do you want to print the bills based on members?([y]/n)")
shouldPrintMembers = readline()
if shouldPrintMembers == "n"
else
    for (name, member) in payGrp.members
        print_member(member)
    end
end

# payment solution
soln = pay_soln(payGrp)
print_soln(soln)

# the end
println()
println("Have a good day ~")
