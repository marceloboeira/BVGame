const assert = require('assert')

// Import the functions we want to test
const { cleanStationName } = require('./pipeline.js')

// Test cases for the cleanStationName function
const testCases = [
  {
    input: "S+U Neukölln (Berlin) [U7]",
    expected: "Neukölln",
    description: "Remove S+U, Berlin in parentheses, and [U7]"
  },
  {
    input: "U AlexanderPlatz (Berlin) [U8]",
    expected: "AlexanderPlatz",
    description: "Remove U prefix, Berlin in parentheses, and [U8]"
  },
  {
    input: "U Bullowstr. (Berlin) [U55]",
    expected: "Bullowstr.",
    description: "Remove U prefix, Berlin in parentheses, and [U55]"
  },
  {
    input: "U Stadmitte U2",
    expected: "Stadmitte",
    description: "Remove U prefix and U2 at the end"
  },
  {
    input: "S+U Rathaus Steglitz (Bhf) [U9]",
    expected: "Rathaus Steglitz",
    description: "Remove S+U, (Bhf), and [U9]"
  },
  {
    input: "Berlin, Foo Bar",
    expected: "Foo Bar",
    description: "Remove Berlin, prefix"
  },
  {
    input: "U5",
    expected: "",
    description: "Single line name should be filtered out (not a real station)"
  },
  {
    input: "U2",
    expected: "",
    description: "Single line name should be filtered out (not a real station)"
  },
  {
    input: "Alexanderplatz U2",
    expected: "Alexanderplatz",
    description: "Remove U2 at the end"
  },
  {
    input: "Spichernstr. U9",
    expected: "Spichernstr.",
    description: "Remove U9 at the end"
  }
]

function runTests() {
  console.log('🧪 Running pipeline tests...\n')
  
  let passed = 0
  let failed = 0
  
  testCases.forEach((testCase, index) => {
    const result = cleanStationName(testCase.input)
    const success = result === testCase.expected
    
    if (success) {
      console.log(`✅ Test ${index + 1}: ${testCase.description}`)
      console.log(`   Input: "${testCase.input}" → Output: "${result}"`)
      passed++
    } else {
      console.log(`❌ Test ${index + 1}: ${testCase.description}`)
      console.log(`   Input: "${testCase.input}" → Expected: "${testCase.expected}" → Got: "${result}"`)
      failed++
    }
    console.log('')
  })
  
  console.log(`📊 Results: ${passed} passed, ${failed} failed`)
  
  if (failed > 0) {
    process.exit(1)
  } else {
    console.log('🎉 All tests passed!')
  }
}

if (require.main === module) {
  runTests()
}

module.exports = { runTests } 